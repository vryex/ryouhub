# Contribuir a Ryou UI

Parte de una rama propia y limita el PR al cambio propuesto. Indica qué API se ve afectada y qué verificaste en Roblox Studio. Para un cambio de layout, incluye capturas del cliente con la resolución visible y reproduce el flujo de [pruebas](docs/testing.md).

Mantén `ui/RyouUI.lua` independiente de lógica de experiencias. Los ejemplos deben funcionar como LocalScripts con el mismo módulo en ReplicatedStorage. Los iconos nuevos deben poder dibujarse en Roblox o usar un ID que quien integra el módulo pueda sustituir por un asset autorizado.
