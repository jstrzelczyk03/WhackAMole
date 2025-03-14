//
//  MoleShape.swift
//  WhackAMole
//
//  Created by Jakub Strzelczyk on 6/27/24.
//

import SwiftUI

struct MoleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let width = rect.width
        let height = rect.height

        path.addEllipse(in: CGRect(x: width * 0.2, y: height * 0.3, width: width * 0.6, height: height * 0.5))

        path.addEllipse(in: CGRect(x: width * 0.35, y: height * 0.1, width: width * 0.3, height: height * 0.3))

        path.addEllipse(in: CGRect(x: width * 0.15, y: height * 0.5, width: width * 0.2, height: height * 0.2))

        path.addEllipse(in: CGRect(x: width * 0.65, y: height * 0.5, width: width * 0.2, height: height * 0.2))

        return path
    }
}

import SwiftUI


import SwiftUI

struct MoleView: View {
    var isGolden: Bool
    var isBlack: Bool
    @State private var isVisible: Bool = false

    var body: some View {
        ZStack {
            MoleShape()
                .fill(isGolden ? Color.yellow : isBlack ? Color.black : Color.brown)
                .scaleEffect(isVisible ? 1.0 : 0.0)
                .animation(.easeOut(duration: 0.5), value: isVisible)
                .onAppear {
                    isVisible = true
                }
                .onDisappear {
                    isVisible = false
                }
            ZStack {
                Circle()
                    .fill(Color.black)
                    .frame(width: 10, height: 10)
                    .offset(x: -10, y: -30)
                Circle()
                    .fill(Color.black)
                    .frame(width: 10, height: 10)
                    .offset(x: 10, y: -30)

                Circle()
                    .fill(Color.pink)
                    .frame(width: 10, height: 10)
                    .offset(y: -20)
            }
            .scaleEffect(isVisible ? 1.0 : 0.0)
            .animation(.easeOut(duration: 0.5), value: isVisible)
        }
        .frame(width: 100, height: 100)
    }
}
