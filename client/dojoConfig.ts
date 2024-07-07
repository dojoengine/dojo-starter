import manifest from './src/manifest.json'
import { createDojoConfig } from '@dojoengine/core'

export const dojoConfig = createDojoConfig({
  manifest,
})
