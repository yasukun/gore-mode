# gore-mode
Launch stack ghci in Emacs

## require

* [gore](https://github.com/motemen/gore)
* go-mode


## git clone.

```bash
$ git clone https://github.com/yasukun/gore-mode
```

## append to .emacs

```elisp
(add-to-list 'load-path "/pathto/gore-mode/")
(autoload 'gore-mode "gore-mode" "Major mode for editing gore." t)
(add-to-list 'auto-mode-alist '("\\.go\\'" . gore-mode))

(add-hook 'gore-mode-hook 'imenu-add-menubar-index)

```
