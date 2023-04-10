//
//  ViewController.swift
//  PlayingCard
//
//  Created by ROBIN.J.Y.ZHONG on 2023/4/10.
//

import UIKit

class ViewController: UIViewController {
    
    var deck = PlayingCardDeck()
    
    @IBOutlet var cardViews: [PlayingCardView]!
    
    lazy var animator = UIDynamicAnimator(referenceView: view)
    
    lazy var cardBehavior = CardBehavior(in: animator)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var cards = [PlayingCard]()
        for _ in 1...(cardViews.count+1)/2 {
            let card = deck.draw()!
            cards += [card, card]
        }
        for cardView in cardViews {
            cardView.isFaceUP = false
            let card = cards.remove(at: cards.count.arc4random)
            cardView.rank = card.rank.order
            cardView.suit = card.suit.rawValue
            cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(flipCard(_:))))
            cardBehavior.addItem(cardView)
        }
    }
    private let scaledTransform = CGAffineTransform.identity.scaledBy(x: 3.0, y: 3.0)
    private var faceUpCardViews: [PlayingCardView] {
        return cardViews.filter{ $0.isFaceUP && !$0.isHidden && $0.transform == .identity && $0.alpha == 1 }
    }
    
    private var faceCardViewMatch: Bool {
        return faceUpCardViews.count == 2 && faceUpCardViews[0] == faceUpCardViews[1]
    }

    var lastChosenCardView: PlayingCardView?
    @objc func flipCard(_ recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            if let chosenCardView = recognizer.view as? PlayingCardView, faceUpCardViews.count < 2 {
                lastChosenCardView = chosenCardView
                cardBehavior.removeItem(chosenCardView)
                UIView.transition(
                    with: chosenCardView,
                    duration: 0.5,
                    options: [.transitionFlipFromLeft],
                    animations: {
                        chosenCardView.isFaceUP = !chosenCardView.isFaceUP
                    },
                    completion: { finished in
                        let cardsToAnimate = self.faceUpCardViews
                        if self.faceCardViewMatch {
//                            UIView.animate(
//                                withDuration:3.0,
//                                animations: {
//                                    self.faceUpCardViews.forEach{
//                                        $0.transform = self.scaledTransform
//                                    }
//                                },
//                                completion: {_ in
//                                    UIView.animate(
//                                        withDuration: 0.75,
//                                        animations: {
//                                            self.faceUpCardViews.forEach{
//                                                $0.transform = CGAffineTransform.identity.scaledBy(x: 0.1, y: 0.1)
//                                                $0.alpha = 0
//                                            }
//                                        },
//                                        completion: {_ in
//                                            self.faceUpCardViews.forEach{
//                                                $0.isHidden = true
//                                                $0.alpha = 1
//                                                $0.transform = .identity
//                                            }
//                                        }
//                                    )
//
//                                }
//                            )
                            UIViewPropertyAnimator.runningPropertyAnimator(
                                withDuration: 0.6,
                                delay: 0,
                                options: [],
                                animations: {
                                    cardsToAnimate.forEach {
                                        $0.transform = CGAffineTransform.identity.scaledBy(x: 3.0, y: 3.0)
                                    }
                                },
                                completion: { position in
                                    UIViewPropertyAnimator.runningPropertyAnimator(
                                        withDuration: 0.75,
                                        delay: 0,
                                        options: [],
                                        animations: {
                                            cardsToAnimate.forEach {
                                                $0.transform = CGAffineTransform.identity.scaledBy(x: 0.1, y: 0.1)
                                                $0.alpha = 0
                                            }
                                        },
                                        completion: { position in
                                            cardsToAnimate.forEach {
                                                $0.isHidden = true
                                                $0.alpha = 1
                                                $0.transform = .identity
                                            }
                                        }
                                    )
                                }
                            )
                        } else if self.faceUpCardViews.count == 2 {
                            if self.lastChosenCardView == chosenCardView {
                                self.faceUpCardViews.forEach { cardView in
                                    UIView.transition(
                                        with: cardView,
                                        duration: 0.5,
                                        options: [.transitionFlipFromLeft],
                                        animations: {
                                            cardView.isFaceUP = false
                                        },
                                        completion: { _ in
                                            self.cardBehavior.addItem(cardView)
                                        }
                                    )
                                    
                                }
                            }
                        } else {
                            if !chosenCardView.isFaceUP {
                                self.cardBehavior.addItem(chosenCardView)
                            }
                        }
                    }
                )
                
            }
        default:
            print("tap card and no action")
            break
        }
       
    }
    
//    @objc func nextCard() {
//        if let card = deck.draw() {
//            playingCardView.rank = card.rank.order
//            playingCardView.suit = card.suit.rawValue
//        }
//    }
//
    

 

}
