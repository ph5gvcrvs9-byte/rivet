//
//  PetView.swift
//  Rivet
//
//  Created by yessa on 5/20/26.
//

import SwiftUI

struct PetView: View {
    @AppStorage("name") private var name: String = "scottie"
    @State private var editingName: Bool = false
    @State private var isTapping = false
    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 10) {

                VStack(alignment: .center) {
                    if editingName {
                        HStack(spacing: 5) {
                            TextField("scottie", text: $name)
                                .font(
                                    Font.custom(
                                        "Jua-Regular",
                                        size: 16
                                    )
                                )
                                .frame(maxWidth: 100)

                                .fixedSize()
                                .onSubmit { editingName = false }
                                .padding(.bottom, 5)

                            Button {
                                withAnimation { editingName = false }
                            } label: {
                                Image(systemName: "checkmark")
                                    .labelStyle(.iconOnly)
                            }
                            .buttonStyle(.plain)
                        }
                        .frame(height: 20)
                    } else {
                        HStack(spacing: 5) {
                            Text(name)
                                .font(
                                    Font.custom(
                                        "Jua-Regular",
                                        size: 16
                                    )
                                )
                            Button {
                                withAnimation { editingName = true }
                            } label: {
                                Image(systemName: "pencil")
                                    .labelStyle(.iconOnly)
                            }
                            .buttonStyle(.plain)
                        }
                        .frame(height: 20)
                    }

                    Text("happy")
                        .font(
                            Font.custom(
                                "Jua-Regular",
                                size: 10
                            )
                        )
                        .foregroundStyle(.yellow)

                    Image("CatNeutralImage")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80)
                        .padding(.top, 5)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { _ in
                                    isTapping = true
                                }
                                .onEnded { _ in
                                    isTapping = false
                                }
                        )
                        .scaleEffect(isTapping ? 2.0 : 1.7)
                        .animation(.bouncy, value: isTapping)
                }

            }
            .padding(5)
            .frame(height: 110)
        }

    }
}

#Preview {
    PetView()
        .padding(10)
}
