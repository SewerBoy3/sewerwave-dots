# Workspace

```text
██╗    ██╗ ██████╗ ███████╗██╗  ██╗
██║    ██║██╔═══██╗██╔════╝██║ ██╔╝
██║ █╗ ██║██║   ██║█████╗  █████╔╝
██║███╗██║██║   ██║██╔══╝  ██╔═██╗
╚███╔███╔╝╚██████╔╝███████╗██║  ██╗
 ╚══╝╚══╝  ╚═════╝ ╚══════╝╚═╝  ╚═╝
```

> Directorios de trabajo preparados por el instalador para organizar tus flujos de trabajo.

El instalador crea tres árboles de trabajo bajo `$HOME`:

## ~/Developer · Web full-stack

```text
Developer/
├── crumbskate-ecommerce/    # Proyectos de e-commerce
├── sewer-world-dashboard/   # Dashboards y apps de administración
└── sandbox/                 # Experimentos y prototipos
```

Stack: Node.js, npm, Brave, Antigravity (según se necesite), SQLite y MariaDB (inicio manual).

---

## ~/GameDev · Godot 4

```text
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

**Consejo:** en tarjetas gráficas integradas como las de un Celeron, configura Godot en **Project → Renderer → Compatibility (GLES3)**.

Las ventanas de Godot se asignan automáticamente al **workspace 3** en i3.

---

## ~/Studio · Música y contenido

```text
Studio/
├── music/{lmms-projects,samples,soundfonts}/
└── content/{guiones,videos/raw,videos/editados,miniaturas}/
```

Los valores por defecto de PipeWire para baja latencia quedan en `~/.config/pipewire/pipewire.conf.d/99-lowlatency.conf`.

Bajá `default.clock.min-quantum` (por ejemplo, de 128 a 64) solo si tu interfaz de audio lo soporta sin xruns.
