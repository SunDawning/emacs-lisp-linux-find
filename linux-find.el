(defun earned:linux-find ()
  "使用Emacs的正则表达式来查找某个目录下符合要求的内容

试图模拟Linux下的find命令"
  (interactive)
  (when buffer-file-name
    (save-buffer))
  (let* ((default-directory (read-directory-name "Directory: " "~/literate-programming/"))
         (regexp (read-string "Regexp: "))
         (name (format "earned:linux-find: %s" (file-name-nondirectory (directory-file-name default-directory)))))
    (when (> (length regexp) 2)
      (when (get-buffer name) (kill-buffer name))
      (let ((buffer (get-buffer-create name))
            (count 0))
        (with-current-buffer buffer
          (dolist (file
                   (cl-sort
                    (directory-files default-directory t)
                    (function >)
                    :key (lambda (filename) (time-to-seconds (nth 5 (file-attributes filename))))))
            (when (string-match "\.org$" file)
              (let ((content
                     (with-temp-buffer
                       (insert-file-contents file)
                       (buffer-string))))
                (let ((matches
                       (reverse
                        (goer--all-matches-as-strings regexp content))))
                  (when matches
                    (insert
                     (format
                      "* [[file:%s][%s]] [0/%s]\n\n"
                      file
                      (file-name-nondirectory file)
                      (length matches))))))))
          (org-mode)
          (view-mode))
        (switch-to-buffer buffer)
        (goto-char (point-min))))))
