#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float uTime;
uniform float uIntensity; // 0.0 (Frio >=50 passos) ate 1.0 (Muito Quente <10 passos)

out vec4 fragColor;

void main() {
    vec2 st = FlutterFragCoord().xy / uSize;

    // Cores obrigatorias do projeto
    vec3 coldColor = vec3(0.53, 0.81, 0.98); // #87CEFA
    vec3 hotColor  = vec3(1.0, 0.27, 0.0);  // #FF4500

    // Interpolacao suave de cores
    vec3 baseColor = mix(coldColor, hotColor, clamp(uIntensity, 0.0, 1.0));

    // Efeito de nevoa e ondulacao de calor dinamico
    float wave = sin(st.x * 10.0 + uTime * 3.0) * cos(st.y * 10.0 + uTime * 2.0) * 0.1;
    
    // Ajusta o brilho da nevoa de acordo com a proximidade
    vec3 finalColor = baseColor + (wave * uIntensity);

    fragColor = vec4(clamp(finalColor, 0.0, 1.0), 1.0);
}
