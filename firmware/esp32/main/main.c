#include <stdio.h>
#include <string.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "esp_log.h"
#include "esp_wifi.h"
#include "esp_event.h"
#include "esp_netif.h"
#include "nvs_flash.h"

static const char *TAG = "CSI_SENSOR";
static volatile uint32_t csi_frames = 0;

static void csi_rx_cb(void *ctx, wifi_csi_info_t *info) {
    if (info == NULL || info->buf == NULL || info->len == 0) return;
    csi_frames++;

    // CSI is interleaved imaginary/real samples. Keep the ISR callback light and
    // emit a compact diagnostic packet; heavy feature extraction belongs in a task.
    if ((csi_frames % 20) == 0) {
        int samples = info->len / 2;
        int64_t energy = 0;
        for (int i = 0; i < info->len; i++) {
            int v = info->buf[i];
            energy += (int64_t)(v < 0 ? -v : v);
        }
        int mean = samples > 0 ? (int)(energy / info->len) : 0;
        ESP_LOGI(TAG, "CSI_FRAME,seq=%lu,len=%d,mean_abs=%d,rssi=%d,channel=%d",
                 (unsigned long)csi_frames, info->len, mean,
                 info->rx_ctrl.rssi, info->rx_ctrl.channel);
    }
}

static void wifi_init(void) {
    ESP_ERROR_CHECK(esp_netif_init());
    ESP_ERROR_CHECK(esp_event_loop_create_default());
    esp_netif_create_default_wifi_sta();

    wifi_init_config_t cfg = WIFI_INIT_CONFIG_DEFAULT();
    ESP_ERROR_CHECK(esp_wifi_init(&cfg));
    ESP_ERROR_CHECK(esp_wifi_set_mode(WIFI_MODE_STA));
    ESP_ERROR_CHECK(esp_wifi_start());

    wifi_csi_config_t csi_config = {
        .lltf_en = true,
        .htltf_en = true,
        .stbc_htltf2_en = true,
        .ltf_merge_en = true,
        .channel_filter_en = true,
        .manu_scale = false,
        .shift = false,
    };

    ESP_ERROR_CHECK(esp_wifi_set_csi_config(&csi_config));
    ESP_ERROR_CHECK(esp_wifi_set_csi_rx_cb(csi_rx_cb, NULL));
    ESP_ERROR_CHECK(esp_wifi_set_csi(true));

    // Promiscuous reception increases the CSI sample rate when the station is
    // not associated. For production, connect to the local router or use a
    // dedicated CSI transmitter for a cleaner sensing link.
    ESP_ERROR_CHECK(esp_wifi_set_promiscuous(true));
}

void app_main(void) {
    esp_err_t nvs = nvs_flash_init();
    if (nvs == ESP_ERR_NVS_NO_FREE_PAGES || nvs == ESP_ERR_NVS_NEW_VERSION_FOUND) {
        ESP_ERROR_CHECK(nvs_flash_erase());
        ESP_ERROR_CHECK(nvs_flash_init());
    } else {
        ESP_ERROR_CHECK(nvs);
    }

    wifi_init();
    ESP_LOGI(TAG, "CSI sensor iniciado. O dispositivo agora coleta alterações do canal Wi-Fi.");
    ESP_LOGI(TAG, "Use um ambiente vazio para a calibração inicial do baseline.");

    while (true) {
        vTaskDelay(pdMS_TO_TICKS(1000));
    }
}
