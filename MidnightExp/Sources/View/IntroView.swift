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
        VStack {
            Image(.logo)
                .resizable()
                .frame(width: isLogDisplaying ? 250 : 200, height: isLogDisplaying ? 250 : 200)
                .padding(.bottom, 24)
            if isLogDisplaying == false {
                Text("스텝프린팅 카메라 MidnightExpress에 오신걸 환영합니다.")
                    .font(.system(size: 20, weight: .semibold, design: .serif))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, 48)
                VStack(alignment: .leading, spacing: 30) {
                    Text("스텝프린팅은 낮은 프레임레이트와 느린 셔터스피드를 통해 정적인 대상과 움직이는 대상을 대비시키는 촬영 기법입니다.")
                    Text("이러한 의도된 대비를 통해 역동적이거나 몽환적인 분위기를 연출할 수 있습니다.")
                    Text("대표적으로 왕가위 감독의 **중경삼림(1994)**, **타락천사(1997)**, **화양연화(2002)** 에서 사용되었으며, 배경에 재생중인 영상 또한 MidnightExpress로 촬영된 스텝프린팅 영상입니다.")
                    HStack {
                        Spacer()
                        Button(action: proceed) {
                            Text("다음")
                                .foregroundStyle(.white)
                                .font(.system(size: 18, weight: .bold, design: .serif))
                                .bottomLined()
                        }
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
                .font(.system(size: 16, weight: .regular, design: .serif))
                .foregroundStyle(.white)
            }
        }
        .transition(.slide)
        .animation(.easeInOut, value: isLogDisplaying)
        .padding(.horizontal, 12)
        .task {
            try? await Task.sleep(for: .seconds(2))
            isLogDisplaying = false
        }
    }
}
