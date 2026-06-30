# Workspace directories

The installer creates three workflow trees under `$HOME`:

## ~/Developer (Web full-stack)

```
Developer/
├── crumbskate-ecommerce/    # E-commerce projects
├── sewer-world-dashboard/   # Dashboard / admin apps
└── sandbox/                 # Experiments, prototypes
```

Stack: Node.js, npm, Chromium, Antigravity (on demand), SQLite, MariaDB (manual start).

## ~/GameDev (Godot 4)

```
GameDev/
├── the-last-crumb/
│   ├── project/
│   ├── assets/{sprites,tilesets,audio}/
│   └── design-docs/
├── dreamfall/
│   ├── project/
│   ├── assets/{sprites,tilesets,audio}/
│   └── design-docs/
└── shared-resources/{pixel-art-refs,godot-addons}/
```

**Tip:** On integrated graphics (Celeron), set Godot **Project → Renderer → Compatibility (GLES3)**.

Godot windows auto-assign to **workspace 3** in i3.

## ~/Studio (Music & content)

```
Studio/
├── music/{lmms-projects,samples,soundfonts}/
└── content/{guiones,videos/raw,videos/editados,miniaturas}/
```

PipeWire low-latency defaults: `~/.config/pipewire/pipewire.conf.d/99-lowlatency.conf`

Lower `default.clock.min-quantum` (e.g. 128 → 64) only if your audio interface supports it without xruns.
