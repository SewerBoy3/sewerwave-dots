# sewerdots

```text
       ███████╗███████╗██╗    ██╗███████╗██████╗
       ██╔════╝██╔════╝██║    ██║██╔════╝██╔══██╗
       ███████╗█████╗  ██║ █╗ ██║█████╗  ██████╔╝
       ╚════██║██╔══╝  ██║███╗██║██╔══╝  ██╔══██╗
       ███████║███████╗╚███╔███╔╝███████╗██║  ██║
       ╚══════╝╚══════╝ ╚══╝╚══╝ ╚══════╝╚═╝  ╚═╝

          ██████╗  ██████╗ ████████╗ ███████╗
          ██╔══██╗ ██╔══██╗╚══██╔══╝ ██╔════╝
          ██║  ██║ ██║  ██║   ██║    ███████╗
          ██║  ██║ ██║  ██║   ██║    ╚════██║
          ██████╔╝ ██████╔╝   ██║    ███████║
          ╚═════╝  ╚═════╝    ╚═╝    ╚══════╝

  ───────────────────────────────────────────────────────
              Fafa  ·  synthwave
                 i3  ·  X11  ·  ligero
```

> Dotfiles e instalador para Arch Linux + i3wm
> Synthwave pastel · bajo consumo · setup en una sola pasada

## ¿Qué es sewerdots?

**sewerdots** transforma una instalación base de Arch Linux en un escritorio completo, elegante y funcional, con una sola ejecución de `./install.sh`.

Está pensado para equipos modestos y para quienes prefieren un flujo claro, sin tener que armar el entorno a mano. La idea es similar a la de [Omakub](https://omakub.org) y [Omarchy](https://omarchy.org): una única entrada para dejar todo listo. La diferencia principal es que aquí se usa **i3wm sobre X11**, con foco en compatibilidad, estabilidad y bajo consumo de RAM.

### Lo que incluye

- **Web:** Antigravity, Brave, Node.js, git, SQLite/MariaDB
- **Videojuegos:** Godot 4, Mesa (compatibilidad/GLES3 recomendado)
- **Audio y contenido:** LMMS, PipeWire con perfil de baja latencia

Las apps pesadas no se autoinician por defecto, así que el escritorio se mantiene ligero y responsive.

---

## Requisitos

- Arch Linux instalado en base (sin metapaquete de escritorio)
- Conexión a internet
- Usuario normal con `sudo`
- `base-devel` (el instalador lo instala si falta)

---

## Instalación

Al ejecutar `./install.sh` se abre un asistente TUI en 5 pasos: bienvenida, workflows, sistema, escritorio y confirmación. Al terminar, guarda tu configuración en `~/.config/sewerdots/installer/choices.conf`.

### 1) Cloná el repositorio

```bash
git clone https://github.com/SewerBoy3/sewerwave-dots.git ~/sewerdots
cd ~/sewerdots
```

### 2) Ejecutá el instalador

```bash
./install.sh
```

> El proceso está guiado por una interfaz tipo terminal, con estética de instalación y pasos claros.

### 3) Personalización avanzada

```bash
./scripts/sewer-config              # hub completo (sin instalar)
./install.sh --configure            # alias al configurador
./install.sh --export-config ~/mi.conf
./install.sh --config ~/mi.conf -y  # reinstalar con tu config
```

Documentación completa de claves en [config/installer/CONFIG.md](config/installer/CONFIG.md).

El hub permite ajustar workflows por componente, i3 gaps, módulos de polybar, picom, PipeWire, paquetes, servicios, rutas e import/export, sin crear carpetas ni estructuras automáticas en tu home.

### One-liner (revisá el script antes)

```bash
curl -fsSL https://raw.githubusercontent.com/SewerBoy3/sewerwave-dots/main/install.sh | bash
```

> Pipear `curl` a `bash` no permite revisar el código antes de ejecutarlo. Lo ideal es clonar el repo y leer el instalador y los scripts antes de correrlo.

El log completo queda en `~/.sewerwave-install.log`.

---

## Después de instalar

1. **Cerrá sesión y volvé a entrar** (o reiniciá) para arrancar la sesión gráfica con i3.
2. Verificá el consumo de RAM en reposo:

```bash
free -h
```

El objetivo es rondar los **~300 MB** justo tras iniciar sesión, sin aplicaciones abiertas.

### Login gráfico opcional (`ly`)

Por defecto se usa **autologin en tty + `startx`**. Si preferís un gestor de login mínimo:

```bash
sudo pacman -S ly
sudo systemctl enable ly.service
```

Comentá el bloque de `startx` en `~/.config/zsh/.zprofile`.

---

## Estructura del repositorio

```text
sewerdots/
├── install.sh          # Orquestador principal
├── config/             # Configs enlazadas a ~/.config/*
├── scripts/            # Pasos modulares de instalación
├── assets/             # Wallpaper, paleta y branding
└── workspace/          # Documentación de referencia para el entorno
```

---

## Atajos de i3

| Teclas | Acción |
|--------|--------|
| `Mod+Return` | Terminal (kitty) |
| `Mod+d` | Lanzador de apps (rofi) |
| `Mod+Shift+q` | Cerrar ventana |
| `Mod+1–0` | Cambiar workspace |
| `Mod+Shift+1–0` | Mover ventana a workspace |

---

## Créditos

Hecho para **Sewer boy** — synthwave pastel para el underground.

## Licencia

MIT — ver [LICENSE](LICENSE).
