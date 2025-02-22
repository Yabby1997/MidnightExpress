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
                instruction: "fps가 작아질수록 단절된 느낌을, 커질수록 연속적인 느낌을 연출할 수 있어요.\nfps를 4로 조절해 단절된 느낌을 연출해 보세요.",
                actionLabel: "건너 뛰기"
            ) { stage.next() }
        case .shutterAngle:
            TutorialStageView(
                instruction: "셔터 앵글이 커질수록 풍부한 잔상을, 작아질수록 적은 잔상을 연출할 수 있어요.\n셔터 앵글을 360도로 조절해 풍부한 잔상을 연출해 보세요.",
                actionLabel: "건너 뛰기"
            ) { stage.next() }
        case .exposureBias:
            TutorialStageView(
                instruction: "노출 보정을 통해 촬영될 결과물의 밝기를 조절할 수 있어요.\n-2.0으로 더 어둡게 조절해 보세요.",
                actionLabel: "건너 뛰기"
            ) { stage.next() }
        case .exposure:
            TutorialStageView(
                instruction: "과노출이나 노출부족이 발생하는 경우 경고가 표시돼요.\nfps와 셔터 앵글을 조절해 노출 문제를 해결할 수 있어요.",
                actionLabel: "확인"
            ) { stage.next() }
        case .zoom:
            TutorialStageView(
                instruction: "줌 슬라이더를 통해 줌 레벨 조절이 가능해요.\n3배 줌을 해보세요.",
                actionLabel: "건너 뛰기"
            ) { stage.next() }
        case .focus:
            TutorialStageView(
                instruction: "초점은 AF로 동작하지만, 특별히 초점을 고정하고 싶은 위치를 탭하면 초점을 고정할 수 있어요.\n고정된 초점은 AF-L 버튼을 탭해 해제할 수 있어요. 초점을 고정해보세요.",
                actionLabel: "건너 뛰기"
            ) { stage.next() }
        case .selfie:
            TutorialStageView(
                instruction: "카메라 전환 버튼을 탭해 전후면 카메라간 전환이 가능해요.\n전후면 카메라를 전환해보세요.",
                actionLabel: "건너 뛰기"
            ) { stage.next() }
        case .record:
            TutorialStageView(
                instruction: "이제 하단 셔터버튼을 눌러 녹화를 시작해보세요!",
                actionLabel: "확인"
            ) { stage.next() }
        case .done: EmptyView()
        }
    }
}
