;; Modalka github https://github.com/mrkkrp/modalka

;; Broadly and simply, avoid creating bindings that would conflict 
;; With muscle memory/intuition from vanilla emacs, and treat
;; Modalka mode as a pseudo-hybrid of Vim's normal and visual modes

;; Modalka Config

(require 'modalka)

(add-hook 'prog-mode-hook #'modalka-mode) ; Modalka for code buffers
(add-hook 'text-mode-hook #'modalka-mode) ; Modalka for text buffers

;; Cursor Tweaks for using Modalka
;; The advice given on the modalka page involves setting the cursor
;; to bar globally and a box for modalka. To get the reverse, of having
;; The cursor change only apply to modes where I use modalka, this is
;; Solution I came up with. It's messy, but I do then use it to set a bar
;; cursor for the minibuffer

(defun cursor-change ()
  "Changes the cursor type when entering/exiting modalka"
  (if (eq cursor-type 'bar)
      (setq cursor-type 'box)
    (setq cursor-type 'bar)))

(setq modalka-cursor-type 'bar)
(add-hook 'modalka-mode-hook 'cursor-change)
(add-hook 'minibuffer-setup-hook 'cursor-change)

;; Global Keybindings for use with Modalka

(global-set-key (kbd "C-;") 'modalka-mode) ; Modal editing toggle

;; General Keybindings
;; Bindinf `h' to `help-map' will

(define-key modalka-mode-map "x" ctl-x-map) ; C-x Map
(define-key modalka-mode-map "h" help-map) ; Help map
(define-key modalka-mode-map "c"
  `(lambda () "Simulates the `C-c' key-press" (interactive)
     (setq prefix-arg current-prefix-arg)
     (setq unread-command-events
	   (listify-key-sequence (read-kbd-macro "C-c"))))) ; C-c prefix

(modalka-define-kbd ";" "C-;") ; Toggle Modalka mode
(modalka-define-kbd "g" "C-g") ; Keyboard Clear
(modalka-define-kbd "u" "C-u") ; Universal-prefix
(modalka-define-kbd "-" "C--") ; Negative Prefix
(modalka-define-kbd "s" "C-s") ; I-search 

;; Numeric Prefixes

(modalka-define-kbd "0" "C-0")
(modalka-define-kbd "1" "C-1")
(modalka-define-kbd "2" "C-2")
(modalka-define-kbd "3" "C-3")
(modalka-define-kbd "4" "C-4")
(modalka-define-kbd "5" "C-5")
(modalka-define-kbd "6" "C-6")
(modalka-define-kbd "7" "C-7")
(modalka-define-kbd "8" "C-8")
(modalka-define-kbd "9" "C-9")

;; Movement & Scrolling

(modalka-define-kbd "b" "C-b") ; Back one Character
(define-key modalka-mode-map (kbd "B") (kbd "C-S-b"))
(modalka-define-kbd "f" "C-f") ; Forward one character
(define-key modalka-mode-map (kbd "F") (kbd "C-S-f"))
(modalka-define-kbd "a" "C-a") ; Beginning of line
(define-key modalka-mode-map (kbd "A") (kbd "C-S-a"))
(modalka-define-kbd "e" "C-e") ; End of line
(define-key modalka-mode-map (kbd "E") (kbd "C-S-e"))
(modalka-define-kbd "p" "C-p") ; Previous Line
(define-key modalka-mode-map (kbd "P") (kbd "C-S-p"))
(modalka-define-kbd "n" "C-n") ; Next Line
(define-key modalka-mode-map (kbd "N") (kbd "C-S-n"))
(modalka-define-kbd "M-p" "M-{") ; Previous Paragraph
(modalka-define-kbd "M-n" "M-}") ; Next paragraph
(modalka-define-kbd "m" "M-m") ; Back to indentation

(define-key modalka-mode-map (kbd "'")
  `(lambda () "move-beginning-of-line and exit modalka" (interactive)
     (call-interactively 'move-beginning-of-line)
     (modalka-mode -1)))
(define-key modalka-mode-map (kbd "\"")
  `(lambda () "move-end-of-line and exit modalka" (interactive)
     (call-interactively 'move-end-of-line)
     (modalka-mode -1)))

(modalka-define-kbd "v" "C-v") ; Move Forward one page
(modalka-define-kbd "<" "M-<") ; Beginning of Buffer
(modalka-define-kbd ">" "M->") ; End of Buffer 
(define-key modalka-mode-map (kbd "l") #'recenter-top-bottom) ; Scroll view around point

;; Mark Control
;; 
;; Vanilla emacs' point and mark system is already great, and extremely powerful.
;; This binds all of it into one place.

(defvar modalka-mark-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd ",") (kbd "M-@")) ; Set mark `arg' words away
    (define-key map (kbd ".") (kbd "M-h")) ; Mark paragraph
    (define-key map (kbd "/") (kbd "C-M-@")) ; Mark s-expression
    (define-key map (kbd "?") (kbd "C-M-h")) ; Mark function
    (define-key map (kbd "<") (kbd "C-x C-p")) ; Mark page
    (define-key map (kbd ">") (kbd "C-x h")) ; Mark buffer
    map))

(define-key modalka-mode-map (kbd "SPC") #'set-mark-command) ; Toggle mark
(modalka-define-kbd "," "C-x C-x") ; Exchange point and mark
(define-key modalka-mode-map (kbd ".") modalka-mark-map) ; Activate the mark map

;; Killing/Yanking

(define-key modalka-mode-map (kbd "d")
  `(lambda ()
     "If a region is selected kill it otherwise delete forward char"
     (interactive)
     (if (use-region-p)
	 (kill-region (region-beginning) (region-end))
       (call-interactively 'delete-forward-char))))

(modalka-define-kbd "w" "M-w") ; Copy region (`d' can delete a region)
(modalka-define-kbd "k" "C-k") ; Kill line
(modalka-define-kbd "y" "C-y") ; Yank last item

;; Undo/Redo

(modalka-define-kbd "/" "C-/") ; Undo
(modalka-define-kbd "?" "C-?") ; Redo

;; Code Editing

(define-key modalka-mode-map (kbd "r")
  `(lambda (&optional char) "Replace the character under point"
     (interactive "cReplace character: ") (insert char)
     (delete-char 1) (backward-char 1)))

(modalka-define-kbd "o" "C-o") ; Open line at point
(modalka-define-kbd "j" "C-j") ; New line (no indent)

(modalka-define-kbd "t" "C-t") ; Transpose characters
(modalka-define-kbd "i" "C-i") ; Indent region/line
(modalka-define-kbd "I" "C-S-i") ; Indent region/line
(modalka-define-kbd ":" "M-;") ; Comment region
(modalka-define-kbd "z" "M-z") ; Zap (kill up to and including) char

;; Unused Keys set to nil for sanity preservation

(modalka-define-kbd "`" "nil")
(modalka-define-kbd "~" "nil")
(modalka-define-kbd "!" "nil")
(modalka-define-kbd "@" "nil")
(modalka-define-kbd "#" "nil")
(modalka-define-kbd "$" "nil")
(modalka-define-kbd "%" "nil")
(modalka-define-kbd "^" "nil")
(modalka-define-kbd "&" "nil")
(modalka-define-kbd "*" "nil")
(modalka-define-kbd "(" "nil")
(modalka-define-kbd ")" "nil")
(modalka-define-kbd "_" "nil")
(modalka-define-kbd "=" "nil")
(modalka-define-kbd "+" "nil")

(modalka-define-kbd "q" "nil")
(modalka-define-kbd "Q" "nil")
(modalka-define-kbd "W" "nil")
(modalka-define-kbd "R" "nil")

(modalka-define-kbd "T" "nil")
(modalka-define-kbd "Y" "nil")
(modalka-define-kbd "U" "nil")
(modalka-define-kbd "O" "nil")
(modalka-define-kbd "[" "nil")
(modalka-define-kbd "]" "nil")
(modalka-define-kbd "{" "nil")
(modalka-define-kbd "}" "nil")
(modalka-define-kbd "\\" "nil")
(modalka-define-kbd "|" "nil")

(modalka-define-kbd "S" "nil")
(modalka-define-kbd "D" "nil")
(modalka-define-kbd "G" "nil")
(modalka-define-kbd "H" "nil")
(modalka-define-kbd "J" "nil")
(modalka-define-kbd "K" "nil")
(modalka-define-kbd "L" "nil")

(modalka-define-kbd "Z" "nil")
(modalka-define-kbd "X" "nil")
(modalka-define-kbd "C" "nil")
(modalka-define-kbd "V" "nil")
(modalka-define-kbd "M" "nil")
