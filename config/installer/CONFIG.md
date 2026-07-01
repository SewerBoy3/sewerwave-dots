# Guía de configuración del instalador sewerdots

## Formas de personalizar

| Método | Comando |
|--------|---------|
| Hub interactivo | `./install.sh` o `./scripts/sewer-config` |
| Solo configurar (sin instalar) | `./scripts/sewer-config` → Guardar y salir |
| Perfil rápido | `./install.sh --profile minimal` |
| Archivo propio | `./install.sh --config mi.conf` |
| Overrides permanentes | `config/installer/local.conf` |
| Reinstalar con tu config | `./install.sh --config ~/.config/sewerdots/installer/choices.conf -y` |

## Secciones

### `[workflows]`
Activá flujos completos y componentes individuales (`webdev_antigravity`, `gamedev_godot`, etc.).

### `[system]`
Login (`startx` / `ly` / `manual`), zRAM, AUR, shell, editor.

### `[desktop]` / `[i3]` / `[polybar]` / `[picom]`
Componentes del escritorio, gaps de i3, módulos de la barra, sombras/blur de picom.

### `[audio]`
`pipewire_latency`: `minimal` | `balanced` | `low`

### `[packages]`
Paquetes opcionales (htop, btop, zellij…).

### `[services]`
Qué demonios habilitar o dejar apagados.

### `[paths]`
Rutas de `~/Developer`, `~/GameDev`, `~/Studio`.

### `[ui]`
`wizard_mode`: `hub` (menú) | `guided` (pasos lineales) | `off`

## Exportar / importar

```bash
./scripts/sewer-config --export ~/mi-sewer.conf
./install.sh --config ~/mi-sewer.conf -y
```
