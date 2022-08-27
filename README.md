# Bubble Shader & Bubble Particle

# 概要 About
シャボン玉っぽい表現ができるパーティクル向けのシェーダーです。
パーティクル向けに作成していますがパーティクル以外にも適用できます。
サンプルとして当シェーダーを設定したマテリアルとパーティクルシステムを同梱しています。

Bubble Shader is the shader for Particle System that can be used to create soap bubble-effects.
It is made for Particle System, but can be applied to Mesh Renderer and Skinned Mesh Renderer as well.
As a sample, A material and Particle system with this shader setup is Included.


# パラメータ Material Parameters
## General Settings
・Base Color
・Base Map
・Smoothness
・Metallic
Standard Shaderと大体同じなので割愛します。
Same as Standard shaders.

・Mask
透明度のマスクです。
Rチャンネルを参照します。
Mask Texture for Opacity.
Refers to Red channel.

・InverseMask
マスクを反転させます。
Invert the Mask Texture value.


## Opacity Settings
透明度に関する設定です。
Settings for Opacity.

・Fresnel Exp
フレネルの指数です。
高いほど中央付近が透明になります。
This value the higher, the more transparent the center area becomes.

・Min Opacity
透明度の最小値です。

・Max Opacity
透明度の最大値です。


## Structural Color Settings
構造色（虹色っぽく見える色）の設定です
Settings for structural color (like a prism color).

・Strength
構造色の強さです。
Structural Color's Strength.

・Emissive Strength
エミッションに反映される構造色の強さです。
Structural Color's Strength for Emissive Color.

・Frequency
構造色の変化をどれだけ急にするか。
Structural Color's Frequency.


## Noise Settings
構造色に加算するノイズの設定です。
Settings for the distortion of structural color.

・Noise Strength
ノイズの強さです。
Noise Strength for Structural Color.

・Noise Frequency
ノイズの周波数です。
高いほどノイズが細かくなります。
Noise Frequency for Structural Color.

・Noise Scroll Speed
ノイズのスクロールする速度です。
Noise Scroll Speed for Structural Color.


## Wave Noise Settings
シャボン玉のたわみ感の設定です。
Settings for the distortion of soap bubble shapes.

・Wave Strength
ノイズの強さです。
Noise Strength for distortion.

・Wave Frequency
ノイズの周波数です。高いほどノイズが細かくなります。
Noise Frequency for distortion.

・Wave Scroll Speed
ノイズのスクロールする速度です。
Noise Scroll Speed for distortion.

・Wave Threshold Size
シャボン玉がたわむ最小サイズです。この値よりスケールが小さいシャボン玉はたわまなくなります。
If bubble's scale smaller than this value, distortion not affect.