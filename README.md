# sewerdots

[![Arch Linux](https://img.shields.io/badge/OS-Arch%20Linux-1793D1?style=for-the-badge&logo=arch-linux)](https://archlinux.org) [![i3wm](https://img.shields.io/badge/WM-i3-black?style=for-the-badge&logo=i3)](https://i3wm.org) [![Brave](https://img.shields.io/badge/Browser-Brave-ED713A?style=for-the-badge&logo=brave)](https://brave.com) [![AUR](https://img.shields.io/badge/AUR-supported-FF9900?style=for-the-badge)](https://aur.archlinux.org)

```text
╔════════════════════════════════════════════════════╗
║      sewerdots — Arch Linux + i3wm synthwave       ║
║   minimal installer · branding · workflows ready   ║
╚════════════════════════════════════════════════════╝
```

> Dotfiles e instalador para Arch Linux + i3wm.
> Estética synthwave pastel con un setup ligero y funcional.

---

## Qué es sewerdots

`sewerdots` instala y configura un entorno i3wm desde una base mínima de Arch Linux.

Pensado para hardware modesto y usuarios que buscan un entorno rápido, estable y con identidad visual.

### Características clave

- Instalación guiada en TUI
- Brave como navegador por defecto
- i3wm sobre X11
- Polybar, picom, kitty, rofi y fastfetch
- Flujos para web, gamedev y audio/contenido

---

## Qué incluye

- **Web:** Brave, Node.js, git, SQLite, MariaDB
- **Videojuegos:** Godot 4, Mesa
- **Audio y contenido:** LMMS, PipeWire baja latencia
- **Escritorio:** i3wm, polybar, picom, kitty, rofi

El sistema permanece ligero: las apps pesadas no se inician automáticamente.

---

## Requisitos

- Arch Linux base instalado
- Conexión a internet
- Usuario con `sudo`
- `base-devel` disponible (se instala si falta)

---

## Instalación

```bash
git clone https://github.com/SewerBoy3/sewerwave-dots.git ~/sewerdots
cd ~/sewerdots
./install.sh
```

El instalador abre un asistente en 5 pasos: bienvenida, workflow, sistema, escritorio y confirmación.

---

## Personalización

```bash
./scripts/sewer-config              # Hub completo sin instalar
./install.sh --configure            # Configura sin ejecutar todo el instalador
./install.sh --export-config ~/mi.conf
./install.sh --config ~/mi.conf -y  # Reinstala con tu config
```

Leé [config/installer/CONFIG.md](config/installer/CONFIG.md) para ver todas las opciones.

---

## Nota importante

El instalador no crea carpetas automáticas en tu home.
Este repo ofrece configuración y base de escritorio sin imponer estructuras personales.

---

## Después de instalar

1. Reiniciá o cerrá sesión y volvé a entrar.
2. Comprobá la RAM en reposo:

```bash
free -h
```

La meta es mantener el sistema liviano sin aplicaciones abiertas.

---

## Login gráfico opcional

Por defecto se usa **autologin en tty + `startx`**.

Para usar un gestor mínimo:

```bash
sudo pacman -S ly
sudo systemctl enable ly.service
```

Comentá el bloque de `startx` en `~/.config/zsh/.zprofile` si activás `ly`.

---

## Estructura del repositorio

```text
sewerdots/
├── install.sh          # Orquestador principal
├── config/             # Configs enlazadas a ~/.config/*
├── scripts/            # Pasos modulares de instalación
├── assets/             # Wallpaper, paleta y branding
└── workspace/          # Documentación de referencia
```

---

## Atajos de i3

| Teclas | Acción |
|--------|--------|
| `Mod+Return` | Terminal (kitty) |
| `Mod+d` | Lanzador (rofi) |
| `Mod+Shift+q` | Cerrar ventana |
| `Mod+1–0` | Cambiar workspace |
| `Mod+Shift+1–0` | Mover ventana a workspace |

---

## Créditos

Hecho para **Sewer boy** con estética synthwave pastel.

## Licencia

MIT — [LICENSE](LICENSE).
