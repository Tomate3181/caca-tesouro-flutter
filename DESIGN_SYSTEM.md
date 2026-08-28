# Documento de Especificação Técnica e Design System

## App: Caça ao Tesouro AR & 3D (Flutter)

---

## 1. Regras de Negócio e Tabela de Estados

A lógica do aplicativo baseia-se na distância calculada entre a posição GPS atual do usuário e as coordenadas do tesouro.


* **Conversão de Passos:** $1 \text{ passo} = 0,8 \text{ metros}$.


* **Desafio:** Gerar latitude/longitude aleatórias a no máximo $60 \text{ metros}$ da posição inicial.



### Mapeamento de Proximidade

| Condição de Passos

 | Distância em Metros | Dica de Proximidade

 | Cor Hex de Fundo

 | Estado do Shader (GLSL) | Ação da UI / AR |
| --- | --- | --- | --- | --- | --- |
| **$\ge 50$ passos** | $\ge 40,0\text{ m}$ | "Frio! Está longe do tesouro." | `#87CEFA` (Azul Claro) | `intensity = 0.0` (Frio, névoa lenta) | Exibe Bússola 3D |
| **$< 50$ passos** | $< 40,0\text{ m}$ | "Morno! Continue procurando." | Transição para Laranja | `intensity = 0.35` (Aumenta pulso) | Exibe Bússola 3D |
| **$< 25$ passos** | $< 20,0\text{ m}$ | "Quente! Está perto!" | Transição para Vermelho | `intensity = 0.70` (Ondulação térmica) | Exibe Bússola 3D + Radar Tátil |
| **$< 10$ passos** | $< 8,0\text{ m}$ | "Muito quente! Está quase lá!" | `#FF4500` (Vermelho) | `intensity = 1.0` (Chamas/Brilho máximo) | **Libera Botão "Modo AR"** |

---

## 2. Dependências (`pubspec.yaml`)

Cole as seguintes dependências no arquivo `pubspec.yaml` do seu projeto Flutter:

```yaml
name: caca_ao_tesouro
description: App de Caça ao Tesouro com AR, Shaders e Bússola 3D.
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  
  # Geolocalização e Bússola[cite: 1]
  geolocator: ^10.1.0
  flutter_compass: ^0.7.0
  
  # Validação de Passos Reais
  pedometer: ^4.0.1
  permission_handler: ^11.3.1

  # Visual 3D e Realidade Aumentada
  flutter_cube: ^0.1.1 # Para a bússola 3D
  ar_flutter_plugin: ^0.7.3 # Para o Baú em Realidade Aumentada

  # Áudio e Feedback Sensorial[cite: 1]
  audioplayers: ^6.0.0
  vibration: ^2.0.1

flutter:
  uses-material-design: true

  # Registro do Shader em GLSL
  shaders:
    - assets/shaders/fog_effect.frag

  # Registro de Assets 3D e Áudio
  assets:
    - assets/models/compass3d.obj
    - assets/models/treasure_chest.gltf
    - assets/audio/victory.mp3

```

---

## 3. Módulo de Cálculo: Bússola 3D, GPS e Pedometer

### 3.1 Matemática da Bússola e Bearing

Para a bússola girar apontando para o tesouro, é necessário calcular o **bearing** (ângulo para o tesouro) e subtrair o **azimuth/heading** (orientação atual do celular):

$$\text{Ângulo da Bússola (\theta)} = \text{BearingToTreasure} - \text{DeviceHeading}$$

```dart
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';

class NavigationController {
  // Posição fixa inicial exigida[cite: 1]
  double treasureLat = -23.11443;
  double treasureLon = -45.70780;

  // Calcula a distância em passos (1 passo = 0.8m)[cite: 1]
  double calculateSteps(Position userPosition) {
    double distanceInMeters = Geolocator.distanceBetween(
      userPosition.latitude,
      userPosition.longitude,
      treasureLat,
      treasureLon,
    );
    return distanceInMeters / 0.8; //[cite: 1]
  }

  // Calcula o ângulo em graus até o tesouro
  double calculateBearing(Position userPosition) {
    return Geolocator.bearingBetween(
      userPosition.latitude,
      userPosition.longitude,
      treasureLat,
      treasureLon,
    );
  }

  // Gerador de Tesouro Aleatório (Desafio Futuro: máximo 60m)[cite: 1]
  void generateRandomTreasure(Position currentPosition) {
    // 60m equivale a ~0.00054 graus geográficos
    final random = DateTime.now().millisecondsSinceEpoch;
    double offsetLat = ((random % 100) - 50) * 0.00001;
    double offsetLon = (((random ~/ 100) % 100) - 50) * 0.00001;
    
    treasureLat = currentPosition.latitude + offsetLat;
    treasureLon = currentPosition.longitude + offsetLon;
  }
}

```

### 3.2 Bússola Interativa em 3D (Eixo Z)

Usando `flutter_cube`, o modelo 3D da bússola gira dinamicamente no eixo Z conforme a direção do tesouro:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_cube/flutter_cube.dart';

class Compass3DView extends StatefulWidget {
  final double targetAngleDegrees; // Ângulo calculado (Bearing - Heading)

  const Compass3DView({super.key, required this.targetAngleDegrees});

  @override
  State<Compass3DView> createState() => _Compass3DViewState();
}

class _Compass3DViewState extends State<Compass3DView> {
  Object? _compassModel;

  void _onSceneCreated(Scene scene) {
    scene.world.add(Object(
      fileName: 'assets/models/compass3d.obj',
      scale: Vector3(3.0, 3.0, 3.0),
      callback: (Object object) {
        _compassModel = object;
        setState(() {});
      },
    ));
    scene.camera.position.setValues(0, 0, 8);
  }

  @override
  Widget build(BuildContext context) {
    if (_compassModel != null) {
      // Converte graus para radianos e aplica rotação no eixo Z
      _compassModel!.rotation.z = widget.targetAngleDegrees * (3.141592653589793 / 180);
      _compassModel!.updateTransform();
    }

    return SizedBox(
      height: 250,
      width: 250,
      child: Cube(onSceneCreated: _onSceneCreated),
    );
  }
}

```

---

## 4. Módulo Visual: Fragment Shader GLSL (`fog_effect.frag`)

Crie o arquivo em `assets/shaders/fog_effect.frag`. O shader interpola nativamente entre o Azul Claro (`#87CEFA`) e o Vermelho (`#FF4500`) com base na intensidade das variáveis do jogo.

```glsl
#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float uTime;
uniform float uIntensity; // 0.0 (Frio >=50 passos) até 1.0 (Muito Quente <10 passos)[cite: 1]

out vec4 fragColor;

void main() {
    vec2 st = FlutterFragCoord().xy / uSize;

    // Cores obrigatórias do projeto[cite: 1]
    vec3 coldColor = vec3(0.53, 0.81, 0.98); // #87CEFA[cite: 1]
    vec3 hotColor  = vec3(1.0, 0.27, 0.0);  // #FF4500[cite: 1]

    // Interpolação suave de cores
    vec3 baseColor = mix(coldColor, hotColor, uIntensity);

    // Efeito de névoa e ondulação de calor dinâmico
    float wave = sin(st.x * 10.0 + uTime * 3.0) * cos(st.y * 10.0 + uTime * 2.0) * 0.1;
    
    // Ajusta o brilho da névoa de acordo com a proximidade
    vec3 finalColor = baseColor + (wave * uIntensity);

    fragColor = vec4(finalColor, 1.0);
}

```

---

## 5. Módulo AR: Realidade Aumentada para Abertura do Baú

Quando a distância for **menor que 10 passos**, a tela de AR é liberada para encontrar o Baú 3D no chão e disparar o áudio final via `audioplayers`.

```dart
import 'package:flutter/material.dart';
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package0/ar_flutter_plugin/models/ar_node.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

class ARTreasureScreen extends StatefulWidget {
  const ARTreasureScreen({super.key});

  @override
  State<ARTreasureScreen> createState() => _ARTreasureScreenState();
}

class _ARTreasureScreenState extends State<ARTreasureScreen> {
  ARObjectManager? arObjectManager;
  ARNode? chestNode;
  final AudioPlayer _audioPlayer = AudioPlayer();

  void onARViewCreated(
    ARSessionManager sessionManager,
    ARObjectManager objectManager,
    ARAnchorManager anchorManager,
    ARLocationManager locationManager,
  ) {
    arObjectManager = objectManager;

    // Detecta toque no Baú 3D no ambiente
    arObjectManager?.onNodeTap = (nodes) {
      if (nodes.contains(chestNode?.name)) {
        _triggerVictory();
      }
    };

    _spawnChest();
  }

  Future<void> _spawnChest() async {
    var newNode = ARNode(
      type: NodeType.localGLTF2,
      uri: "assets/models/treasure_chest.gltf",
      scale: vector.Vector3(0.4, 0.4, 0.4),
      position: vector.Vector3(0.0, -0.4, -0.8), // 80cm à frente no chão
    );

    bool? added = await arObjectManager?.addNode(newNode);
    if (added == true) {
      chestNode = newNode;
    }
  }

  Future<void> _triggerVictory() async {
    // Toca música de vitória exigida[cite: 1]
    await _audioPlayer.play(AssetSource('audio/victory.mp3'));

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("🏆 PARABÉNS!"),
        content: const Text("Você encontrou o tesouro lendário!"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Procure o Baú no Chão!")),
      body: ARView(onARViewCreated: onARViewCreated),
    );
  }
}

```

---

## 6. Guia Passo a Passo de Execução

Para concluir a entrega dentro do horário estipulado:

1. **Passo 1 (Projeto & Permissões):**
* Crie o app Flutter e adicione as permissões de **Câmera**, **Localização (GPS)** e **Atividade Física (Pedometer)** nos arquivos `AndroidManifest.xml` e `Info.plist`.


2. **Passo 2 (Desenvolvimento do Core - Integrante 1):**
* Implemente o `Geolocator` e a matemática de conversão de distância para passos ($1 \text{ passo} = 0,8\text{ m}$).


* Garanta que as dicas de proximidade em texto ("Muito quente", "Quente", "Morno", "Frio") estejam funcionando corretamente.




3. **Passo 3 (Visual Shader e Bússola 3D - Integrante 2):**
* Compile o Fragment Shader GLSL e conecte a variável `uIntensity` à distância calculada pelo GPS.


* Configure o widget `flutter_cube` com o modelo 3D da bússola girando com os dados do `flutter_compass`.


4. **Passo 4 (Realidade Aumentada e Áudio - Integrante 3):**
* Integre a tela do `ar_flutter_plugin` ativada apenas quando os passos forem $<10$.


* Vincule o evento de clique no baú ao `audioplayers` para tocar o áudio final de vitória.




5. **Passo 5 (Validação e Git):**
* Teste a troca para valores aleatórios em um raio de 60 metros.


* Suba o repositório no GitHub para realizar a entrega oficial.