import { frontendURL } from '../../../helper/URLHelper';
import ExternalAppIndex from './Index.vue';

const permissions = ['administrator', 'agent', 'custom_role'];

export const routes = [
  {
    path: frontendURL('accounts/:accountId/crm'),
    name: 'crm_index',
    meta: { permissions, externalApp: 'crm' },
    component: ExternalAppIndex,
  },
  {
    path: frontendURL('accounts/:accountId/captar'),
    name: 'captar_index',
    meta: { permissions, externalApp: 'captar' },
    component: ExternalAppIndex,
  },
];
