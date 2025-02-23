//
//  IntroView.swift
//  MidnightExp
//
//  Created by Seunghun on 2/19/25.
//  Copyright © 2025 seunghun. All rights reserved.
//

import SwiftUI


struct IntroView: View {
    @State private var isLogDisplaying = true
    let proceed: () -> Void
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                Image(.logo)
                    .resizable()
                    .frame(width: isLogDisplaying ? 250 : 200, height: isLogDisplaying ? 250 : 200)
                if isLogDisplaying == false {
                    Spacer()
                    VStack(alignment: .leading, spacing: 30) {
                        Text("Midnight Express는 스텝프린팅 카메라입니다.")
                        Text("스텝프린팅은 낮은 프레임레이트와 느린 셔터스피드를 통해 정적인 대상과 움직이는 배경을 대비시키고 역동적이거나 몽환적인 분위기를 연출합니다.")
                        Text("대표적으로 왕가위 감독의 영화 **중경삼림(1994)**, **타락천사(1997)** 그리고 **화양연화(2002)** 에서 활용되었습니다.")
                    }
                    .padding(.horizontal, 16)
                    Spacer()
                }
                Spacer()
            }
            if isLogDisplaying == false {
                VStack {
                    Spacer()
                    Button { proceed() } label: {
                        Text("Next")
                    }
                }
            }
        }
        .font(.system(size: 16))
        .transition(.slide)
        .animation(.easeInOut, value: isLogDisplaying)
        .onAppear {
            Task {
                try? await Task.sleep(for: .seconds(1.5))
                isLogDisplaying = false
            }
        }
    }
}

