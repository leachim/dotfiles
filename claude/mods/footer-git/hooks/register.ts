import { atom, read, update } from 'claude-code'
import type { Register } from 'claude-code'

// What bin/claude-footer printed last: "~/.dotfiles main@b40cce9* ↑2".
const tail = atom({ plugin: 'footer-git', key: 'tail' } as const, '')

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    const started = await next(e)

    const refresh = async () => {
      const cwd = await $.session.cwd()
      const ran = await $.process.run(
        ['bash', '-c', 'exec "$HOME/.dotfiles/bin/claude-footer" "$1"', '_', cwd],
        { timeoutMs: 5000 },
      )
      const text = ran.exitCode === 0 ? ran.stdout.trim() : ''
      await update($, tail, () => text)
    }

    void refresh().catch(() => undefined)
    $.clock.every(5000, () => void refresh().catch(() => undefined))

    return started
  })

  on('ui.render', { component: 'PromptHint' }, async ($, e, next) => {
    const text = await read($, tail)

    return text ? next({ ...e, props: { ...e.props, tail: `  ${text}` } }) : next(e)
  })
}
