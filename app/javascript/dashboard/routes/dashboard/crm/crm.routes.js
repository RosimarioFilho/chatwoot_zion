import { frontendURL } from '../../../helper/URLHelper';
import CrmIndex from './Index.vue';

export const routes = [
  {
    path: frontendURL('accounts/:accountId/crm'),
    name: 'crm_index',
    meta: {
      permissions: ['administrator', 'agent', 'custom_role'],
    },
    component: CrmIndex,
  },
];
