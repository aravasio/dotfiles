// attention — mark the terminal tile when OpenCode is waiting for YOU.
//
//   session.idle / permission.asked / question.asked
//     -> kitty tab turns orange, i3 tile goes urgent (red border +
//        workspace button), dunst notification, short sound.
//   session.status busy
//     -> everything back to normal.
//
// i3 clears the urgent flag by itself when the window gains focus.
// The plugin never throws: worst case, no indicator.

import type { Plugin } from "@opencode-ai/plugin"

const TAB_WAITING = "#ffa41f" // Monokai Boosted orange
const SOUND_WAITING = "/usr/share/sounds/freedesktop/stereo/message.oga"

async function run(cmd: string[]) {
  try {
    const p = Bun.spawn(cmd, { stdout: "ignore", stderr: "ignore" })
    await p.exited
  } catch {
    /* indicator is best-effort */
  }
}

async function isFocused(): Promise<boolean> {
  const wid = process.env.WINDOWID
  if (!wid) return false
  try {
    const p = Bun.spawn(["xdotool", "getactivewindow"], {
      stdout: "pipe",
      stderr: "ignore",
    })
    const out = (await new Response(p.stdout).text()).trim()
    await p.exited
    return out === String(Number(wid))
  } catch {
    return false
  }
}

async function setUrgent(on: boolean) {
  const wid = process.env.WINDOWID
  if (!wid) return
  await run(["xdotool", "set_window", "--urgency", on ? "1" : "0", wid])
}

async function tabColor(color: string) {
  const listen = process.env.KITTY_LISTEN_ON
  const win = process.env.KITTY_WINDOW_ID
  if (!listen || !win) return
  const arg = color === "NONE" ? "active_bg=NONE" : `active_bg=${color}`
  await run([
    "kitten", "@", "--to", listen, "set-tab-color",
    "--match", `window_id:${win}`, arg,
  ])
}

async function mark(title: string, body: string, urgency: string) {
  await tabColor(TAB_WAITING)
  if (await isFocused()) return // you're already looking at it
  await setUrgent(true)
  await run(["notify-send", "-a", "OpenCode", "-u", urgency, "-t", "6000", title, body])
  await run(["paplay", SOUND_WAITING])
}

async function clear() {
  await tabColor("NONE")
  await setUrgent(false)
}

export const Attention: Plugin = async () => {
  return {
    event: async ({ event }) => {
      switch (event.type) {
        case "session.idle":
          await mark("  OpenCode terminó", "esperando tu input", "normal")
          break
        case "permission.asked":
          await mark("󰭹  OpenCode te necesita", "pide un permiso", "critical")
          break
        case "question.asked":
          await mark("󰭹  OpenCode te necesita", "te hizo una pregunta", "critical")
          break
        case "session.status":
          if (event.properties.status.type === "busy") await clear()
          break
      }
    },
  }
}

export default Attention
