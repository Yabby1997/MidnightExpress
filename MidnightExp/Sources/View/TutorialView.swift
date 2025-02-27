//
//  TutorialView.swift
//  MidnightExp
//
//  Created by Seunghun on 2/22/25.
//  Copyright © 2025 seunghun. All rights reserved.
//

import SwiftUI

struct TutorialView: View {
    @Binding var stage: TutorialStage
    
    var body: some View {
        switch stage {
        case .fps:
            TutorialStageView(
                tutorial: "프레임레이트가 작아질수록 단절된 영상을,\n커질수록 연속적인 영상을 촬영할 수 있어요.",
                instruction: "프레임레이트를 4로 조절해 차이를 느껴보세요."
            )
        case .shutterAngle:
            TutorialStageView(
                tutorial: "셔터앵글이 커질수록 부드럽고 풍부한 잔상을,\n작아질수록 적은 잔상을 연출할 수 있어요.",
                instruction: "셔터앵글을 360도로 조절해 차이를 느껴보세요."
            )
        case .exposureBias:
            TutorialStageView(
                tutorial: "노출보정값이 작을수록 어두운 영상을,\n커질수록 밝은 영상을 촬영할 수 있어요.",
                instruction: "노출보정값을 -2.0으로 조절해 차이를 느껴보세요."
            )
        case .exposure:
            TutorialStageView(
                tutorial: "빛이 부족하거나 과다한 경우 다음과 같이 경고가 표시돼요.\n프레임레이트와 셔터앵글을 조절해 문제를 해결할 수 있어요.",
                instruction: nil
            )
        case .zoom:
            TutorialStageView(
                tutorial: "줌 슬라이더를 통해 영상을 확대할 수 있어요.",
                instruction: "줌 슬라이더를 통해 2배 줌을 해보세요."
            )
        case .focus:
            TutorialStageView(
                tutorial: "특정 지점을 탭해 해당 지점에 초점을 고정,\nAF-L 버튼을 탭해 초점 고정을 해제할 수 있어요.",
                instruction: "원하는 지점에 초점을 고정해보세요."
            )
        case .selfie:
            TutorialStageView(
                tutorial: "카메라 전환 버튼을 탭해 전/후면 카메라 전환이 가능해요.",
                instruction: "전면 카메라로 전환해보세요."
            )
        case .record:
            TutorialStageView(
                tutorial: "이제 하단 셔터버튼을 눌러 촬영을 시작해보세요.",
                instruction: nil
            )
        case .done: EmptyView()
        }
    }
}
