<script setup>
import { ref, onMounted } from 'vue';
import axios from 'axios';
import { useMapGetter } from 'dashboard/composables/store';

const accountId = useMapGetter('getCurrentAccountId');
const iframeSrc = ref('');
const state = ref('loading'); // loading | ready | error

onMounted(async () => {
  try {
    const { data } = await axios.get(
      `/api/v1/accounts/${accountId.value}/crm/sso_token`
    );
    iframeSrc.value = `${data.url}/sso?token=${encodeURIComponent(data.token)}`;
    state.value = 'ready';
  } catch (error) {
    state.value = 'error';
  }
});
</script>

<template>
  <div class="flex flex-col w-full h-full bg-n-background">
    <iframe
      v-if="state === 'ready'"
      :src="iframeSrc"
      title="Zion CRM"
      class="w-full h-full border-0"
      allow="clipboard-write"
    />
    <div
      v-else
      class="flex flex-1 justify-center items-center text-sm text-n-slate-11"
    >
      <span v-if="state === 'loading'">Carregando CRM…</span>
      <span v-else>Não foi possível abrir o CRM. Tente novamente.</span>
    </div>
  </div>
</template>
