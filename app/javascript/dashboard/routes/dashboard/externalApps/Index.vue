<script setup>
import { ref, computed, watch, onMounted } from 'vue';
import { useRoute } from 'vue-router';
import { useI18n } from 'vue-i18n';
import { useMapGetter } from 'dashboard/composables/store';

const route = useRoute();
const { t } = useI18n();

const accountId = useMapGetter('getCurrentAccountId');
const iframeSrc = ref('');
const state = ref('loading'); // loading | ready | error

// A rota diz qual app companheiro abrir (crm | captar); o backend devolve a URL
// e o JWT curto de SSO daquele app.
const appKey = computed(() => route.meta?.externalApp);
const title = computed(() => t(`SIDEBAR.${appKey.value === 'captar' ? 'CAPTAR' : 'ZION_CRM'}`));

const loadApp = async () => {
  if (!appKey.value || !accountId.value) return;
  state.value = 'loading';
  try {
    // window.axios e a instancia autenticada do Chatwoot (com os headers do
    // devise). O `import axios` cru nao carrega a autenticacao -> 401.
    const { data } = await window.axios.get(
      `/api/v1/accounts/${accountId.value}/external_apps/${appKey.value}/sso_token`
    );
    iframeSrc.value = `${data.url}/sso?token=${encodeURIComponent(data.token)}`;
    state.value = 'ready';
  } catch (error) {
    state.value = 'error';
  }
};

onMounted(loadApp);
watch(appKey, loadApp);
</script>

<template>
  <div class="flex flex-col w-full h-full bg-n-background">
    <iframe
      v-if="state === 'ready'"
      :src="iframeSrc"
      :title="title"
      class="w-full h-full border-0"
      allow="clipboard-write"
    />
    <div
      v-else
      class="flex flex-1 justify-center items-center text-sm text-n-slate-11"
    >
      <span v-if="state === 'loading'">
        {{ $t('EXTERNAL_APPS.LOADING', { app: title }) }}
      </span>
      <span v-else>{{ $t('EXTERNAL_APPS.ERROR', { app: title }) }}</span>
    </div>
  </div>
</template>
