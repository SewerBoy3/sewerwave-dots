# Guía de configuración del instalador sewerdots

```text
███████╗██╗███╗   ██╗ ██████╗ ███████╗███████╗
██╔════╝██║████╗  ██║██╔═══██╗██╔════╝██╔════╝
███████╗██║██╔██╗ ██║██║   ██║███████╗███████╗
╚════██║██║██║╚██╗██║██║   ██║╚════██║╚════██║
███████║██║██║ ╚████║╚██████╔╝███████║███████║
╚══════╝╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚══════╝╚══════╝
```

> Personalizá el setup sin perder la coherencia visual ni la lógica del instalador.

## Formas de personalizar

| Método | Comando |
|--------|---------|
| Hub interactivo | `./install.sh` o `./scripts/sewer-config` |
| Solo configurar (sin instalar) | `./scripts/sewer-config` → guardar y salir |
| Perfil rápido | `./install.sh --profile minimal` |
| Archivo propio | `./install.sh --config mi.conf` |
| Overrides permanentes | `config/installer/local.conf` |
| Reinstalar con tu config | `./install.sh --config ~/.config/sewerdots/installer/choices.conf -y` |

---

## Secciones

### `[workflows]`
Activá flujos completos y componentes individuales como `webdev_antigravity`, `gamedev_godot` y otros.

El navegador web por defecto del flujo de desarrollo es Brave.

### `[system]`
Controlá login (`startx`, `ly` o `manual`), zRAM, AUR, shell y editor.

### `[desktop]`, `[i3]`, `[polybar]` y `[picom]`
Ajustá componentes del escritorio, gaps de i3, módulos de la barra y sombras o blur de picom.

### `[audio]`
`pipewire_latency`: `minimal` | `balanced` | `low`

### `[packages]`
Paquetes opcionales como htop, btop, zellij y otros.

### `[services]`
Qué demonios habilitar y qué dejar apagado.

### `[paths]`
Rutas de `~/Developer`, `~/GameDev` y `~/Studio`.

### `[ui]`
`wizard_mode`: `hub` (menú) | `guided` (pasos lineales) | `off`

---

## Exportar e importar

```bash
./scripts/sewer-config --export ~/mi-sewer.conf
./install.sh --config ~/mi-sewer.conf -y
```
