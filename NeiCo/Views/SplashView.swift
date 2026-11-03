import SwiftUI

struct SplashView: View {
    @Binding var isActive: Bool

    // controls the initial fade-in of N and C
    @State private var showLetters = false
    // drives the glow pulse
    @State private var glow = false
    // when true, we enter the “join” phase
    @State private var joinPhase = false
    // when true, we spin the C
    @State private var spinning = false
    // controls the offset of C as it moves to touch N
    @State private var cOffset: CGFloat = 0

    // base font size for N & C
    private let baseSize: CGFloat = 128

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if !joinPhase {
                // Initial: N and C side by side with glow
                HStack(spacing: baseSize * 0.6) {
                    Text("N")
                        .font(.system(size: baseSize, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .white.opacity(glow ? 0.6 : 0.2),
                                radius: glow ? 30 : 10)
                    Text("C")
                        .font(.system(size: baseSize, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .white.opacity(glow ? 0.6 : 0.2),
                                radius: glow ? 30 : 10)
                }
                .opacity(showLetters ? 1 : 0)
                .onAppear {
                    // Fade in letters
                    withAnimation(.easeOut(duration: 0.5)) {
                        showLetters = true
                    }
                    // Start glow pulse
                    withAnimation(Animation.easeInOut(duration: 1.0)
                                    .repeatForever(autoreverses: true)) {
                        glow = true
                    }
                    // After pause, move to join
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            joinPhase = true
                            // compute offset so C’s left edge touches N’s right edge:
                            // letter width ≈ baseSize * 0.6 (monospaced-ish)
                            cOffset = -(baseSize * 0.6) / 2
                        }
                    }
                }

            } else {
                // Join phase: C grows larger and slides to touch N
                ZStack {
                    Text("N")
                        .font(.system(size: baseSize, weight: .bold))
                        .foregroundColor(.white)

                    Text("C")
                        .font(.system(size: baseSize * 1.5, weight: .bold))
                        .foregroundColor(.white)
                        .offset(x: cOffset)
                        // once in place, start spinning
                        .rotationEffect(.degrees(spinning ? 360 : 0))
                        .onAppear {
                            withAnimation(Animation.linear(duration: 1.2)
                                            .repeatForever(autoreverses: false)) {
                                spinning = true
                            }
                        }
                }
                .onAppear {
                    // After a moment spinning, dismiss splash
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        withAnimation(.easeOut(duration: 0.5)) {
                            isActive = false
                        }
                    }
                }
            }
        }
    }
}
