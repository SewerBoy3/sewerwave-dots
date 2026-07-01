# sewerdots

**Dotfiles e instalador para Arch Linux + i3wm — estética Synthwave Pastel de Sewer boy.**

<!-- TODO: screenshot -->

## Objetivo

**sewerdots** convierte una instalación base de Arch Linux (sin entorno de escritorio) en un sistema completo, listo para trabajar, con una sola ejecución de `./install.sh`.

Está pensado para hardware modesto — **Celeron de 2 núcleos y 4 GB de RAM** — y prioriza consumo bajo de recursos sobre efectos visuales pesados. La filosofía es similar a [Omakub](https://omakub.org) y [Omarchy](https://omarchy.org): un único punto de entrada, sin ricing manual después. A diferencia de Omarchy (Hyprland/Wayland), **sewerdots usa i3wm sobre X11** a propósito: mejor compatibilidad con gráficos integrados viejos y menos RAM en reposo (~300 MB con i3, picom, polybar y wallpaper, sin apps abiertas).

Incluye tres flujos de trabajo opcionales:

- **Web:** Antigravity, Chromium, Node.js, git, SQLite/MariaDB
- **Videojuegos:** Godot 4, Mesa (renderer Compatibility/GLES3 recomendado)
- **Audio y contenido:** LMMS, PipeWire con perfil de baja latencia

Las apps pesadas **no se autoinician**; el escritorio queda liviano para que corran bajo demanda.

## Requisitos

- Arch Linux instalado en base (sin metapaquete de escritorio)
- Conexión a internet
- Usuario normal con **sudo**
- **base-devel** (el instalador lo instala si falta)

## Instalación

Al ejecutar `./install.sh` se abre un **asistente TUI en 5 pasos** (gum): bienvenida, workflows, sistema, escritorio y confirmación. Al terminar guarda tu config en `~/.config/sewerdots/installer/choices.conf`.

Cloná el repositorio y ejecutá el instalador:

```bash
git clone https://github.com/SewerBoy3/sewerwave-dots.git ~/sewerdots
cd ~/sewerdots
./install.sh
```

### Personalización avanzada

```bash
./scripts/sewer-config              # hub completo (sin instalar)
./install.sh --configure            # alias al configurador
./install.sh --export-config ~/mi.conf
./install.sh --config ~/mi.conf -y  # reinstalar con tu config
```

Documentación de **todas las claves**: [`config/installer/CONFIG.md`](config/installer/CONFIG.md)

El hub permite ajustar workflows por componente, i3 gaps, módulos polybar, picom, PipeWire, paquetes, servicios, rutas, import/export.

### One-liner (revisá el script antes)

```bash
curl -fsSL https://raw.githubusercontent.com/SewerBoy3/sewerwave-dots/main/install.sh | bash
```

> **Seguridad:** pipear `curl` a `bash` no te deja auditar el código. Preferí clonar el repo y leer `install.sh` y `scripts/` antes de ejecutar.

El log completo queda en `~/.sewerwave-install.log`.

### Después de instalar

1. **Cerrá sesión y volvé a entrar** (o reiniciá) para arrancar la sesión gráfica con i3.
2. Verificá el consumo de RAM en reposo:

```bash
free -h
```

El objetivo es ~300 MB justo tras iniciar sesión, sin aplicaciones abiertas.

### Login gráfico opcional (`ly`)

Por defecto se usa **autologin en tty + `startx`**. Si preferís un gestor de login mínimo:

```bash
sudo pacman -S ly
sudo systemctl enable ly.service
```

Comentá el bloque de `startx` en `~/.config/zsh/.zprofile`.

## Estructura del repositorio

```
sewerdots/
├── install.sh          # Orquestador (ejecuta scripts/ en orden)
├── config/             # Se enlaza a ~/.config/*
├── scripts/            # Pasos modulares de instalación
├── assets/             # Wallpaper, paleta, branding
└── workspace/          # Documentación de ~/Developer, ~/GameDev, ~/Studio
```

## Atajos de i3

| Teclas | Acción |
|--------|--------|
| `Mod+Return` | Terminal (kitty) |
| `Mod+d` | Lanzador de apps (rofi) |
| `Mod+Shift+q` | Cerrar ventana |
| `Mod+1–0` | Cambiar workspace |
| `Mod+Shift+1–0` | Mover ventana a workspace |

## Créditos

Hecho para **Sewer boy** — synthwave pastel para el underground.

## Licencia

MIT — ver [LICENSE](LICENSE).
