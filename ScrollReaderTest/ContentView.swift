//
//  ContentView.swift
//  ScrollReaderTest
//
//  Created by Taehyung Lee on 2022/08/29.
//

import SwiftUI

private struct OffsetPreferenceKey: PreferenceKey {
    
    static var defaultValue: CGPoint = .zero
    
    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) { }
}

struct OffsettableScrollView<T: View>: View {

    let axes: Axis.Set
    let showsIndicator: Bool
    let onOffsetChanged: (CGPoint) -> Void
    let content: T
    
    init(axes: Axis.Set = .vertical,
         showsIndicator: Bool = true,
         onOffsetChanged: @escaping (CGPoint) -> Void = { _ in },
         @ViewBuilder content: () -> T
    ) {
        self.axes = axes
        self.showsIndicator = showsIndicator
        self.onOffsetChanged = onOffsetChanged
        self.content = content()
    }

    var body: some View {
            ScrollView(axes, showsIndicators: showsIndicator) {
                GeometryReader { proxy in
                    Color.clear.preference(
                        key: OffsetPreferenceKey.self,
                        value: proxy.frame(
                            in: .named("ScrollViewOrigin")
                        ).origin
                    )
                }
                .frame(width: 0, height: 0)
                content
            }
            .coordinateSpace(name: "ScrollViewOrigin")
            .onPreferenceChange(OffsetPreferenceKey.self,
                                perform: onOffsetChanged)
    }
}

struct ContentView: View {
    
    @StateObject var viewModel = ViewModel()
    
    var body: some View {
        ZStack {
            ScrollViewReader { scrollView in
                VStack {
                    HStack {
                        Button("Scroll to bottom") {
                            withAnimation {
                                scrollView.scrollTo(viewModel.list.last?.id, anchor: .bottom)
                            }
                        }
                        .padding()
                        Button("Add Item") {
                            viewModel.addItem()
                        }
                        .padding()
                        Spacer()
                    }
                    
                    RefreshableScrollView { complete in
//                        scrollView.scrollTo(viewModel.scrollTarget, anchor: .center)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            viewModel.appendPrevItem()
                            complete()
                        }
                        
                    } progress: { state in
                        if state == .waiting {
                            Text("Pull me down...")
                        } else if state == .primed {
                            Text("Now release!")
                        }  else if state == .loading {
                            Text("Loading...")
                        } else {
                            Text("Working...")
                        }
                    } content: {
                        LazyVStack {
                            ForEach(viewModel.list) { item in
                                //LazyVStack : 내부 View가 실제로 필요할 때 View가 그려짐
                                //VStack : 시작할때 전부 그림
                                VStack {
                                    HStack {
                                        Text(item.title)
                                            .padding()
                                        Spacer()

                                    }
                                    
                                    Divider()
                                }
                                .id(item.id)
                                .onAppear {
                                    // LazyVStack 특성을 활용하여 그려질려고 할때 어떤 처리를 추가로 할수있음
                                    if item.id == viewModel.list.last?.id {
                                        viewModel.appendNextItem()
                                    }
                                    
                                }
                            }
                            EmptyView()
                                
                        }
                        
                    }
                    .onChange(of: viewModel.scrollTarget) { target in
                        var up:UnitPoint = .bottom
                        if viewModel.scrollState == .prevLoad {
                            up = .top
                        }
//                        withAnimation {
                            scrollView.scrollTo(target, anchor: up)
//                        }
                    }
//                    .onReceive(viewModel.$list, perform: { list in
//                        viewModel.scrollTarget = list.last?.id
//                    })

                }

            }

        }
    }
}

