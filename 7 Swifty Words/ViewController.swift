//
//  ViewController.swift
//  7 Swifty Words
//
//  Created by Camilo Hernández Guerrero on 27/06/22.
//

import UIKit

class ViewController: UIViewController {
    var cluesLabel: UILabel!
    var answersLabel: UILabel!
    var currentAnswer: UITextField!
    var scoreLabel: UILabel!
    var letterButtons = [UIButton]()
    var activatedButtons = [UIButton]()
    var solutions = [String]()
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var level = 1
    var counter = 0
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
        
        scoreLabel = UILabel()
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.textAlignment = .right
        scoreLabel.text = "Score: 0"
        view.addSubview(scoreLabel)
        
        cluesLabel = UILabel()
        cluesLabel.translatesAutoresizingMaskIntoConstraints = false
        cluesLabel.font = UIFont.systemFont(ofSize: 24)
        cluesLabel.text = "CLUES"
        cluesLabel.numberOfLines = 0
        cluesLabel.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
        view.addSubview(cluesLabel)
        
        answersLabel = UILabel()
        answersLabel.translatesAutoresizingMaskIntoConstraints = false
        answersLabel.font = UIFont.systemFont(ofSize: 24)
        answersLabel.text = "ANSWERS"
        answersLabel.textAlignment = .right
        answersLabel.numberOfLines = 0
        answersLabel.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
        view.addSubview(answersLabel)
        
        currentAnswer = UITextField()
        currentAnswer.translatesAutoresizingMaskIntoConstraints = false
        currentAnswer.placeholder = "Tap letters to guess"
        currentAnswer.textAlignment = .center
        currentAnswer.font = UIFont.systemFont(ofSize: 44)
        currentAnswer.isUserInteractionEnabled = false
        view.addSubview(currentAnswer)
        
        let submit = UIButton(type: .system)
        submit.translatesAutoresizingMaskIntoConstraints = false
        submit.setTitle("SUBMIT", for: .normal)
        submit.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        view.addSubview(submit)
        
        let clear = UIButton(type: .system)
        clear.translatesAutoresizingMaskIntoConstraints = false
        clear.setTitle("CLEAR", for: .normal)
        clear.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
        view.addSubview(clear)
        
        let buttonsView = UIView()
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        buttonsView.layer.borderWidth = 1
        buttonsView.layer.borderColor = CGColor(gray: 0.7, alpha: 1)
        view.addSubview(buttonsView)
        
        NSLayoutConstraint.activate(
            [scoreLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
             scoreLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
             
             cluesLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor),
             cluesLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 100),
             cluesLabel.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.6, constant: -100),
             
             answersLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor),
             answersLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -100),
             answersLabel.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.4, constant: -100),
             answersLabel.heightAnchor.constraint(equalTo: cluesLabel.heightAnchor),
             
             currentAnswer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
             currentAnswer.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
             currentAnswer.topAnchor.constraint(equalTo: cluesLabel.bottomAnchor, constant: 20),
             
             submit.topAnchor.constraint(equalTo: currentAnswer.bottomAnchor),
             submit.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -100),
             submit.heightAnchor.constraint(equalToConstant: 44),
             
             clear.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 100),
             clear.centerYAnchor.constraint(equalTo: submit.centerYAnchor),
             clear.heightAnchor.constraint(equalToConstant: 44),
             
             buttonsView.widthAnchor.constraint(equalToConstant: 750),
             buttonsView.heightAnchor.constraint(equalToConstant: 320),
             buttonsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
             buttonsView.topAnchor.constraint(equalTo: submit.bottomAnchor, constant: 20),
             buttonsView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -20)
            ])
        
        let width = 150
        let height = 80
        
        for row in 0..<4 {
            for column in 0..<5 {
                let letterButton = UIButton(type: .system)
                letterButton.titleLabel?.font = UIFont.systemFont(ofSize: 36)
                letterButton.setTitle("WWW", for: .normal)
                letterButton.addTarget(self, action: #selector(letterTapped), for: .touchUpInside)
                letterButton.frame = CGRect(x: column * width, y: row * height, width: width, height: height)
    
                buttonsView.addSubview(letterButton)
                letterButtons.append(letterButton)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadLevel()
    }
    
    func loadLevel() {
        var clueString = ""
        var solutionsString = ""
        var letterBits = [String]()
        
        DispatchQueue.global(qos: .userInteractive).async {
            [weak self] in
            
            if let levelFileURL = Bundle.main.url(forResource: "level\(self!.level)", withExtension: "txt") {
                if let levelContents = try? String(contentsOf: levelFileURL) {
                    var lines = levelContents.components(separatedBy: "\n")
                    lines.shuffle()
                    
                    for (index, line) in lines.enumerated() {
                        let parts = line.components(separatedBy: ": ")
                        let answer = parts[0]
                        let clue = parts[1]
                        
                        clueString += "\(index + 1). \(clue)\n"
                        
                        let solutionWord = answer.replacingOccurrences(of: "|", with: "")
                        solutionsString += "\(solutionWord.count) letters\n"
                        self?.solutions.append(solutionWord)
                        
                        let bits = answer.components(separatedBy: "|")
                        letterBits += bits
                    }
                }
            }
        }

        DispatchQueue.main.async {
            [weak self] in
            guard let numberOfButtons = self?.letterButtons.count else { return }
            
            self?.cluesLabel.text = clueString.trimmingCharacters(in: .whitespacesAndNewlines)
            self?.answersLabel.text = solutionsString.trimmingCharacters(in: .whitespacesAndNewlines)
            self?.letterButtons.shuffle()
            
            if numberOfButtons == letterBits.count {
                for i in 0..<numberOfButtons {
                    self?.letterButtons[i].setTitle(letterBits[i], for: .normal)
                }
            }
        }
    }
    
    @objc func letterTapped (_ sender: UIButton) {
        guard let buttonTitle = sender.titleLabel?.text else { return }
        
        currentAnswer.text = currentAnswer.text?.appending(buttonTitle)
        activatedButtons.append(sender)
        
        UIView.animate(withDuration: 1, delay: 0.1, options: []) {
            sender.alpha = 0
        } completion: { _ in
            sender.isHidden = true
        }
    }
    
    @objc func submitTapped (_ sender: UIButton) {
        counter = 0
        guard let answerText = currentAnswer.text else { return }
        var alertController = UIAlertController(title: "The answer is empty", message: "Please submit a valid answer.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Got it!", style: .default))
        
        if answerText == "" {
            present(alertController, animated: true)
        } else if let solutionPosition =  solutions.firstIndex(of: answerText) {
            activatedButtons.removeAll()
            
            var splitAnswers = answersLabel.text?.components(separatedBy: "\n")
            splitAnswers?[solutionPosition] = answerText
            answersLabel.text = splitAnswers?.joined(separator: "\n")
            
            currentAnswer.text = ""
            score += 1
            
            for letterButton in letterButtons {
                if letterButton.isHidden {
                    counter += 1
                }
            }
            
            if counter == letterButtons.count {
                if level == 1 {
                    alertController = UIAlertController(title: "Well done!", message: "Are you ready for the next level?", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Let's go!", style: .default, handler: levelUp))
                    
                } else {
                    alertController.title = "Game finished!"
                    alertController.message = "You have passed the game with a score of \(score), well done!"
                }
                
                present(alertController, animated: true)
            }
        } else {
            score -= 1
            alertController.title = "Wrong answer"
            alertController.message = "Clear it and try again!"
            present(alertController, animated: true)
        }
    }
    
    func levelUp(action: UIAlertAction) {
        DispatchQueue.global(qos: .userInteractive).async {
            [weak self] in
            self?.level += 1
            self?.solutions.removeAll(keepingCapacity: true)
            self?.loadLevel()
        }
        
        DispatchQueue.main.async {
            [weak self] in
            guard let buttons = self?.letterButtons else { return }
            
            for button in buttons {
                button.isHidden = false
            }
        }
    }
    
    @objc func clearTapped (_ sender: UIButton) {
        currentAnswer.text = ""
        
        for activatedButton in activatedButtons {
            activatedButton.isHidden = false
            
            UIView.animate(withDuration: 1, delay: 0.1) {
                activatedButton.alpha = 1
            }
        }
        
        activatedButtons.removeAll(keepingCapacity: true)
    }
}
