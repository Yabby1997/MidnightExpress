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
                tutorial: "tutorialViewFPSDescription",
                instruction: "tutorialViewFPSInstruction"
            )
        case .shutterAngle:
            TutorialStageView(
                tutorial: "tutorialViewShutterAngleDescription",
                instruction: "tutorialViewShutterAngleInstruction"
            )
        case .exposureBias:
            TutorialStageView(
                tutorial: "tutorialViewExposureBiasDescription",
                instruction: "tutorialViewExposureBiasInstruction"
            )
        case .exposure:
            TutorialStageView(
                tutorial: "tutorialViewExposureAlertDescription",
                instruction: nil
            )
        case .zoom:
            TutorialStageView(
                tutorial: "tutorialViewZoomDescription",
                instruction: "tutorialViewZoomInstruction"
            )
        case .focus:
            TutorialStageView(
                tutorial: "tutorialViewFocusDescription",
                instruction: "tutorialViewFocusInstruction"
            )
        case .selfie:
            TutorialStageView(
                tutorial: "tutorialViewSelfieDescription",
                instruction: "tutorialViewSelfieInstruction"
            )
        case .record:
            TutorialStageView(
                tutorial: "tutorialViewRecordDescription",
                instruction: nil
            )
        case .done: EmptyView()
        }
    }
}
