# SubAbyss - Technical Specification & Game Design Document (GDD / PRD)

**Nombre en clave:** Project: SubAbyss (Submarinos 3D)
**Plataforma objetivo:** Dispositivos móviles (Build inicial: APK Android / Escalable a iOS)
**Género:** Combate Naval Submarino Táctico 3D / Cooperativo Asimétrico / Extracción y Crafteo
**Inspiración central:** *World of Tanks* (peso táctico, balística y posicionamiento) + *Warframe* (progresión, farmeo de planos, mods modulares y habilidades fijas de chasis).

---

## 1. Resumen del Concepto y Core Loop

### 1.1 Premisa Central
Juego de combate submarino en 3D en tiempo real donde cada submarino es tripulado por 3 jugadores humanos en roles asimétricos y complementarios:
- **Navegante:** Movilidad, gobierno, sigilo y marcación táctica.
- **Artillero:** Balística, selección de munición, cálculo de trayectorias y disparo.
- **Oficial de Defensa:** Detección perimetral, contramedidas, órdenes evasivas y control de daños mediante minijuegos.

### 1.2 Dimensionamiento de Partida (PvP)
- **3 Submarinos vs. 3 Submarinos.**
- **18 jugadores humanos simultáneos por partida** (3 tripulantes × 6 naves).

### 1.3 Core Gameplay Loop
```
[Farmeo PvE / Misiones de Extracción]
               │
               ▼
[Astillero: Planos + Aleaciones + Microchips] ──> [Desbloqueo de Nuevos Submarinos y Armas]
               │
               ▼
[Personalización de Loadouts y Módulos]
               │
               ▼
[Combate Competitivo PvP / Jefes Abisales]
```

---

## 2. Sistema de Tripulación: Roles y Mecánicas

### Rol 1: Navegante (Gobierno y Propulsión)

#### Física de Navegación 3D (6 Grados de Libertad Hidrodinámicos):
- **Viraje (Yaw):** Giro sobre eje horizontal asistido por timón.
- **Inclinación (Pitch):** Ajuste de proa ascendente/descendente para inmersión dinámica.
- **Cota Vertical Directa (Heave):** Vaciado/llenado de tanques de lastre para ganar o perder profundidad en posición neutra.
- **Inercia:** El casco no frena en seco; requiere contrarruta o deslizamiento (*drift*) hidrodinámico.

#### Selector de Velocidades (Gears):
- **Estático (0%):** Firma acústica base. Flotabilidad neutra.
- **Lento (30%):** Movimiento silencioso de aproximación táctica.
- **Medio (65%):** Crucero estándar de combate y exploración.
- **Rápido / Flanco (100%):** Máxima aceleración. Provoca cavitación de turbinas (delata posición en todo el mapa).

#### Modo Sigilo (Silent Running):
- Velocidad reducida fija (20%), ruido de propulsores = 0 dB.
- **Ventana activa:** 12 a 15 segundos.
- **Cooldown obligatorio:** 30 segundos tras apagado para enfriar baterías.

#### Maniobras de Emergencia:
- **Inmersión de Emergencia (Crash Dive):** Caída violenta de cota (Z) para romper líneas de fijación de torpedos.
- **Uso de Termoclinas:** Posicionar el casco por encima/debajo de gradientes térmicos para rebotar sonares activos rivales.

---

### Rol 2: Artillero (Ofensiva y Balística)

#### Estructura del Arsenal (Loadout de Combate):
- **3 Armas Configurables (Pre-partida):**
  - *Slot 1 (Principal):* Torpedos acústicos pesados o torpedos perforantes de impacto.
  - *Slot 2 (Secundario / Rápido):* Torpedos ultrarrápidos de supercavitación o misiles de cápsula boya a superficie.
  - *Slot 3 (Táctico / Negación de Zona):* Minas magnéticas ancladas, cargas sónicas PEM o cargas de racimo.
- **2 Habilidades Fijas del Submarino (Inmutables por Chasis):**
  - Definidas por el modelo del casco (ej. Lanzador de Fantasmas Acústicos, Sobrecarga de Tubos para disparo doble instantáneo).

#### Mecánicas de Tiro y Balística Marina:
- **Retícula de Predicción Asistida (Vector Lead):** Calcula el punto futuro de impacto según la velocidad y ángulo del objetivo.
- **Sinergia con Navegación:** Si el Navegante mantiene al rival fijado con el sonar, la retícula es 100% estable. Si hay pérdida de línea acústica, la retícula tiembla o se oculta.
- **Torpedos Filoguiados (Teledirigidos):** Control manual del torpedo en trayectoria mediante giroscopio/trackpad móvil.

#### Firma Acústica por Disparo (Mecánica de Exposición):
- Disparar un arma pesada genera un pico masivo de decibelios (100+ dB) que revela la posición exacta del submarino en el mapa enemigo durante **5 segundos**, salvo que se empleen torpedos especiales de gas frío o habilidades de supresión de cavitación.

---

### Rol 3: Oficial de Defensa (Detección y Control de Daños)

#### Radar Perimetral 360° e Hidrófonos:
- Monitoreo de amenazas entrantes en 3D.
- Cálculo y visualización en tiempo real del **TTI (Time to Impact)** de los torpedos enemigos.

#### Arsenal de Contramedidas Activas:
- **Noisemakers (Señuelos acústicos):** Desvían torpedos con buscador sónico.
- **Pantalla de Microburbujas:** Dispersa ondas de sonar y ciega radares enemigos en la zona.
- **Hard-Kill:** Cargas defensivas de intercepción en rango cercano.

#### Sinergia Cooperativa: Orden Evasiva:
- Si las contramedidas fallan o están en recarga, el Defensor emite una *Orden Evasiva* contextual.
- El Navegante recibe una alerta crítica con una ventana de reacción de 2 a 3 segundos.
- Si el Navegante pulsa la acción a tiempo, el submarino ejecuta una maniobra forzada que desvía el torpedo o reduce el daño en un **80%**.

#### Control de Daños (Minijuegos Táctiles de 3 a 5 Segundos):
- **Vía de Agua / Inundación:** Tocar puntos de presión para sellar mamparos antes de que el peso hunda el casco a la cota de aplastamiento.
- **Falla de Turbinas:** Deslizar potenciómetros para estabilizar la frecuencia del reactor.
- **Tubos Bloqueados:** Puentear conexiones eléctricas mediante unión de circuitos de colores.

---

## 3. Entorno de Batalla y Dinámica de Mapas

### 3.1 Geografía Marina Táctica
- **Arrecifes de Coral:** Cobertura blanda destructible por proyectiles de alto calibre.
- **Cuevas y Cavernas Abisales:** Combate cerrado que bloquea fijaciones de largo alcance pero multiplica los rebotes de sonar.
- **Fosas Abisales:** Zonas de alta presión al borde de la cota de aplastamiento (*Crush Depth*), ideales para emboscadas silenciosas.

### 3.2 Eventos Catastróficos Dinámicos (Levolution)
El servidor ejecuta eventos aleatorios a mitad de partida que cambian las condiciones:
- **Erupción de Volcán Submarino:** Inutiliza los sonares térmicos y genera corrientes de agua hirviendo que dañan el casco.
- **Tsunami / Corrientes Abisales:** Desvían la trayectoria balística de los torpedos y arrastran el submarino si no se compensa el timón.
- **Derrumbes Sísmicos:** Colapso de cavernas y caída de monolitos de piedra detectables previamente por el Defensor.

### 3.3 Fauna Marina Hostil (Creeps Neutrales con Buffs)
- **Coloso Abisal (Calamar Gigante / Monstruo de Fosa):** Ataca a submarinos que usen sonar activo o velocidad de flanco. Derrotarlo otorga el buff *Tinta Abisal* (invisibilidad al radar por 20 seg) o regeneración de casco.
- **Cardúmenes de Anguilas Electromagnéticas:** Derrotarlas otorga *Batería Sobrecargada* (-30% tiempos de enfriamiento).

### 3.4 Suministros Tácticos (Orbes y Cofres)
- Aparecen un máximo de 3 veces por partida en zonas neutrales disputadas.
- Tienen un tiempo de apertura de 4 segundos a velocidad cero o lenta.
- **Tipos de drops:**
  - *Orbe de Reparación Estructural:* Repara brechas críticas e inunda tanques de aire.
  - *Orbe de Resonancia:* Resetea de inmediato todos los cooldowns de armas y contramedidas.
  - *Orbe de Sobrecarga:* Recarga al 100% la habilidad definitiva del submarino.

---

## 4. Modos de Juego

### 4.1 Modos PvP (Arenas Competitivas)
- **Duelo a Muerte por Equipos (3v3 Subs):** 18 jugadores. Formato al mejor de 3 rondas o vidas compartidas por escuadrón.
- **Rey del Foso (King of the Trench):** Zona de control esférica submarina que se reubica aleatoriamente en distintas cotas de profundidad cada 90 segundos.
- **Captura del Núcleo Abisal:** Infiltración en base rival para remolcar un reactor magnético penalizando la velocidad de la nave portadora.

### 4.2 Modo PvE Cooperativo (Loop de Progresión estilo Warframe)
- **Star Chart Submarino:** Mapa de sectores oceánicos con nodos de misiones interconectadas.
- **Tipos de Misión:**
  - *Supervivencia:* Mantener la energía del reactor recogiendo cápsulas de oxígeno de patrullas enemigas.
  - *Defensa Móvil:* Escolta y protección de sondas mineras automáticas.
  - *Sabotaje:* Infiltración en complejos industriales sumergidos, sobrecarga de reactores y extracción contrarreloj.
  - *Asesinato:* Cacería de Leviatanes biomecánicos o Súper-Submarinos nodriza con mecánicas de fases y puntos débiles.
- **Cápsulas de Carga Perdidas (Reliquias del Vacío):**
  - Obtenidas en misiones regulares.
  - Se abren en misiones de Fisuras Abisales.
  - Al extraer, la tripulación puede elegir entre las recompensas obtenidas por cualquiera de los 3 miembros, facilitando la obtención de planos de Submarinos Élite / Primigenios.

---

## 5. Sistema de Progresión y Crafteo (Astillero y Microchips)

### 5.1 El Astillero (Foundry)
Para construir un nuevo submarino se requiere recolectar y ensamblar:
- Plano General del Casco (Blueprint)
- Componente de Casco (*Hull*): Titanio Marino y Compuestos Cerámicos.
- Componente de Propulsión (*Engine*): Turbinas de Inducción y Polímeros.
- Componente de Sensores (*Avionics*): Cristales de Cuarzo y Cableado superconductor.
- Componente de Reactor (*Power Core*): Células de Fisión / Núcleos Abisales.

### 5.2 Sistema de Microchips (Mods)
- **Capacidad de Energía Base** (ej. 30 pts / 60 pts con Reactor de Resonancia instalado).
- **Sistema de Polaridades:** Ranuras con símbolos; colocar un chip que coincida con la polaridad divide a la mitad su costo de energía.
- **Daño Elemental Combinado:**
  - *Térmico:* Genera recalentamiento continuo de sistemas.
  - *Criogénico:* Congela timones y reduce velocidad de giro.
  - *Corrosivo:* Disuelve el blindaje metálico reduciendo la mitigación de daño.
  - *Magnético / PEM:* Drena reservas de energía y distorsiona el radar del Defensor rival.

---

## 6. Arquitectura Técnica de Red (Mobile APK)

```
              [SERVIDOR DEDICADO / AUTORITATIVO]
                 Simula: Física rígida del casco, proyectiles,
                 entorno, colisiones, eventos dinámicos.
                               ▲
       ┌───────────────────────┼───────────────────────┐
       │ RPCs / Inputs         │ Snapshot Sync         │ RPCs / Inputs
       ▼                       ▼                       ▼
[CLIENTE 1]               [CLIENTE 2]             [CLIENTE 3]
 Navegante                 Artillero                Defensa
(Predicción local de      (Interpolación suave     (Radar perimetral,
    movimiento)             de periscopio)           minijuegos UI)
```

### 6.1 Sincronización de Tripulación (Pawn Multi-Ocupante)
- **Entidad Única en Servidor:** El submarino existe como un solo actor físico rígido en el servidor.
- **Jerarquía de Clientes:**
  - El Navegante tiene autoridad de simulación predictiva local para eliminar sensación de lag al girar o acelerar.
  - El Artillero y el Defensor reciben transformadas interpoladas del casco para evitar vibraciones o saltos en la cámara de puntería.
- **Manejo de Desconexiones Móviles (Pérdida de señal 4G/5G):**
  - Si un jugador se desconecta, entra una IA de transición que mantiene el rol en modo automático básico (ej. el artillero dispara a objetivos fijados; la defensa activa contramedidas con 70% de efectividad) hasta la reconexión del jugador humano.

---

## 7. Roadmap de Fases de Desarrollo

- **Fase 1 (Prototipo Físico y Red LAN):**
  - Casco 3D navegable con 6DoF y selector de marchas.
  - Sincronización de 3 clientes en un único submarino con roles diferenciados.
- **Fase 2 (Sistemas de Combate):**
  - Balística de torpedos, retícula de predicción asistida y radares 360°.
  - Implementación de contramedidas y minijuegos de reparación para Defensa.
- **Fase 3 (Alpha PvP 3v3):**
  - Primer mapa de pruebas con 6 submarinos (18 conexiones simultáneas).
  - Modo Duelo a Muerte y Rey del Foso funcional.
- **Fase 4 (Entorno Dinámico y Mapas):**
  - Cuevas, corales destructibles, eventos de volcán/tsunami y creeps neutrales.
- **Fase 5 (PvE, Astillero y Progresión):**
  - Base de datos de inventario, sistema de planos, crafteo con tiempos de espera y sistema de microchips (mods).
