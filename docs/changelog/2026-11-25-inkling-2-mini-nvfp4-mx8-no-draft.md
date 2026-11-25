# 2026-11-25 - Inkling 2 Mini en Basalt sin borrador

## Qué

`basalt/scripts/models/inkling-2-mini-nvfp4-mx8/text-262k.json` añade `"spec": 1`, que desactiva el borrador DSpark. El
alias, el contexto (262.144) y la caché KV (`int8`) no cambian, así que los clientes tampoco.

## Por qué

Decisión del usuario, para todos los perfiles de este modelo, tras comparar cuatro variantes con las mismas peticiones
(ver «Comparación de variantes» en la [ficha](../overview/models/inkling-2-mini-nvfp4-mx8.md)). Sin borrador, la prosa
pasa de 67,5 a 83,6 tok/s y el prefill de 41K de 3.255 a 3.766 tok/s, porque los 0,48 GiB del borrador pasan a expertos
(1.959 en RAM al inicio, frente a 2.339). Código, herramientas y la generación tras un prompt largo bajan un 6-18 %.

## Pruebas

La configuración se midió como variante (misma configuración con otro nombre de archivo), no arrancando de nuevo el
lanzador.
