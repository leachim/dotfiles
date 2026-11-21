export type Tail = string

declare module 'claude-code' {
  interface PluginState {
    'footer-git': { tail: Tail }
  }
}
