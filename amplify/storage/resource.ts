import { defineStorage } from '@aws-amplify/backend';

export const storage = defineStorage({
  name: 'repsLoggerStorage',
  access: (allow) => ({
    'entries/{entity_id}/*': [
      allow.entity('identity').to(['read', 'write', 'delete']),
    ],
  })
});

