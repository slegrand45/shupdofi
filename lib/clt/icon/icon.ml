(* https://fonts.google.com/icons?icon.set=Material+Icons *)

open Vdom

let input ~class_attr =
  svg_elt "svg" ~a:[attr "width" "1.5em"; attr "height" "1.5em"; attr "fill" "currentColor"; attr "class" class_attr;
                    attr "viewBox" "0 0 24 24"] [
    svg_elt "g" ~a:[attr "fill" "none"][
      svg_elt "path" ~a:[attr "d" "M0 0h24v24H0V0z"; attr "fill" "none"][];
      svg_elt "path" ~a:[attr "d" "M0 0h24v24H0V0z"; attr "opacity" ".87"][];
    ];
    svg_elt "path" ~a:[attr "d" "M21 3.01H3c-1.1 0-2 .9-2 2V9h2V4.99h18v14.03H3V15H1v4.01c0 1.1.9 1.98 2 1.98h18c1.1 0 2-.88 2-1.98v-14c0-1.11-.9-2-2-2zM11 16l4-4-4-4v3H1v2h10v3zM21 3.01H3c-1.1 0-2 .9-2 2V9h2V4.99h18v14.03H3V15H1v4.01c0 1.1.9 1.98 2 1.98h18c1.1 0 2-.88 2-1.98v-14c0-1.11-.9-2-2-2zM11 16l4-4-4-4v3H1v2h10v3z"][];
  ]

let warning_amber ~class_attr =
  svg_elt "svg" ~a:[attr "width" "1.5em"; attr "height" "1.5em"; attr "fill" "currentColor"; attr "class" class_attr;
                    attr "viewBox" "0 0 24 24"] [
    svg_elt "path" ~a:[attr "d" "M12 5.99L19.53 19H4.47L12 5.99M12 2L1 21h22L12 2zm1 14h-2v2h2v-2zm0-6h-2v4h2v-4z"][];
  ]

let folder ~class_attr =
  svg_elt "svg" ~a:[attr "width" "1.5em"; attr "height" "1.5em"; attr "fill" "currentColor"; attr "class" class_attr;
                    attr "viewBox" "0 0 24 24"] [
    svg_elt "path" ~a:[attr "d" "M0 0h24v24H0V0z"; attr "fill" "none"][];
    svg_elt "path" ~a:[attr "d" "M9.17 6l2 2H20v10H4V6h5.17M10 4H4c-1.1 0-1.99.9-1.99 2L2 18c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V8c0-1.1-.9-2-2-2h-8l-2-2z"][];
  ]

let settings ~class_attr =
  svg_elt "svg" ~a:[attr "width" "1.5em"; attr "height" "1.5em"; attr "fill" "currentColor"; attr "class" class_attr;
                    attr "viewBox" "0 0 24 24"] [
    svg_elt "path" ~a:[attr "d" "M0 0h24v24H0V0z"; attr "fill" "none"][];
    svg_elt "path" ~a:[attr "d" "M19.43 12.98c.04-.32.07-.64.07-.98 0-.34-.03-.66-.07-.98l2.11-1.65c.19-.15.24-.42.12-.64l-2-3.46c-.09-.16-.26-.25-.44-.25-.06 0-.12.01-.17.03l-2.49 1c-.52-.4-1.08-.73-1.69-.98l-.38-2.65C14.46 2.18 14.25 2 14 2h-4c-.25 0-.46.18-.49.42l-.38 2.65c-.61.25-1.17.59-1.69.98l-2.49-1c-.06-.02-.12-.03-.18-.03-.17 0-.34.09-.43.25l-2 3.46c-.13.22-.07.49.12.64l2.11 1.65c-.04.32-.07.65-.07.98 0 .33.03.66.07.98l-2.11 1.65c-.19.15-.24.42-.12.64l2 3.46c.09.16.26.25.44.25.06 0 .12-.01.17-.03l2.49-1c.52.4 1.08.73 1.69.98l.38 2.65c.03.24.24.42.49.42h4c.25 0 .46-.18.49-.42l.38-2.65c.61-.25 1.17-.59 1.69-.98l2.49 1c.06.02.12.03.18.03.17 0 .34-.09.43-.25l2-3.46c.12-.22.07-.49-.12-.64l-2.11-1.65zm-1.98-1.71c.04.31.05.52.05.73 0 .21-.02.43-.05.73l-.14 1.13.89.7 1.08.84-.7 1.21-1.27-.51-1.04-.42-.9.68c-.43.32-.84.56-1.25.73l-1.06.43-.16 1.13-.2 1.35h-1.4l-.19-1.35-.16-1.13-1.06-.43c-.43-.18-.83-.41-1.23-.71l-.91-.7-1.06.43-1.27.51-.7-1.21 1.08-.84.89-.7-.14-1.13c-.03-.31-.05-.54-.05-.74s.02-.43.05-.73l.14-1.13-.89-.7-1.08-.84.7-1.21 1.27.51 1.04.42.9-.68c.43-.32.84-.56 1.25-.73l1.06-.43.16-1.13.2-1.35h1.39l.19 1.35.16 1.13 1.06.43c.43.18.83.41 1.23.71l.91.7 1.06-.43 1.27-.51.7 1.21-1.07.85-.89.7.14 1.13zM12 8c-2.21 0-4 1.79-4 4s1.79 4 4 4 4-1.79 4-4-1.79-4-4-4zm0 6c-1.1 0-2-.9-2-2s.9-2 2-2 2 .9 2 2-.9 2-2 2z"][];
  ]

let home ~class_attr =
  svg_elt "svg" ~a:[attr "width" "1.5em"; attr "height" "1.5em"; attr "fill" "currentColor"; attr "class" class_attr;
                    attr "viewBox" "0 0 24 24"] [
    svg_elt "path" ~a:[attr "d" "M0 0h24v24H0V0z"; attr "fill" "none"][];
    svg_elt "path" ~a:[attr "d" "M12 5.69l5 4.5V18h-2v-6H9v6H7v-7.81l5-4.5M12 3L2 12h3v8h6v-6h2v6h6v-8h3L12 3z"][];
  ]

let account_circle ~class_attr =
  svg_elt "svg" ~a:[attr "width" "1.5em"; attr "height" "1.5em"; attr "fill" "currentColor"; attr "class" class_attr;
                    attr "viewBox" "0 0 24 24"; attr "enable-background" "new 0 0 24 24"] [
    svg_elt "rect" ~a:[attr "width" "1.5em"; attr "height" "1.5em"; attr "fill" "none"][];
    svg_elt "path" ~a:[attr "d" "M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zM7.35 18.5C8.66 17.56 10.26 17 12 17s3.34.56 4.65 1.5c-1.31.94-2.91 1.5-4.65 1.5s-3.34-.56-4.65-1.5zm10.79-1.38C16.45 15.8 14.32 15 12 15s-4.45.8-6.14 2.12C4.7 15.73 4 13.95 4 12c0-4.42 3.58-8 8-8s8 3.58 8 8c0 1.95-.7 3.73-1.86 5.12z"][];
    svg_elt "path" ~a:[attr "d" "M12 6c-1.93 0-3.5 1.57-3.5 3.5S10.07 13 12 13s3.5-1.57 3.5-3.5S13.93 6 12 6zm0 5c-.83 0-1.5-.67-1.5-1.5S11.17 8 12 8s1.5.67 1.5 1.5S12.83 11 12 11z"][];
  ]

let file_upload ~class_attr =
  svg_elt "svg" ~a:[attr "width" "1.5em"; attr "height" "1.5em"; attr "fill" "currentColor"; attr "class" class_attr;
                    attr "viewBox" "0 0 24 24"; attr "enable-background" "new 0 0 24 24"] [
    svg_elt "rect" ~a:[attr "width" "1.5em"; attr "height" "1.5em"; attr "fill" "none"][];
    svg_elt "path" ~a:[attr "d" "M18,15v3H6v-3H4v3c0,1.1,0.9,2,2,2h12c1.1,0,2-0.9,2-2v-3H18z M7,9l1.41,1.41L11,7.83V16h2V7.83l2.59,2.58L17,9l-5-5L7,9z"][];
  ]

let file_download ~label ~class_attr =
  svg_elt "svg" ~a:[attr "width" "1.5em"; attr "height" "1.5em"; attr "fill" "currentColor"; attr "class" class_attr;
                    attr "viewBox" "0 0 24 24"; attr "enable-background" "new 0 0 24 24"; attr "aria-labelledby" "icon-title-file-download"; attr "role" "img"] [
    svg_elt "title" ~a:[attr "id" "icon-title-file-download"] [text label];
    svg_elt "rect" ~a:[attr "width" "1.5em"; attr "height" "1.5em"; attr "fill" "none"][];
    svg_elt "path" ~a:[attr "d" "M18,15v3H6v-3H4v3c0,1.1,0.9,2,2,2h12c1.1,0,2-0.9,2-2v-3H18z M17,11l-1.41-1.41L13,12.17V4h-2v8.17L8.41,9.59L7,11l5,5 L17,11z"][];
  ]

let edit ~label ~class_attr =
  svg_elt "svg" ~a:[attr "width" "1.5em"; attr "height" "1.5em"; attr "fill" "currentColor"; attr "class" class_attr;
                    attr "viewBox" "0 0 24 24"; attr "enable-background" "new 0 0 24 24"; attr "aria-labelledby" "icon-title-edit"; attr "role" "img"] [
    svg_elt "title" ~a:[attr "id" "icon-title-edit"] [text label];
    svg_elt "path" ~a:[attr "d" "M0 0h24v24H0V0z"; attr "fill" "none"][];
    svg_elt "path" ~a:[attr "d" "M14.06 9.02l.92.92L5.92 19H5v-.92l9.06-9.06M17.66 3c-.25 0-.51.1-.7.29l-1.83 1.83 3.75 3.75 1.83-1.83c.39-.39.39-1.02 0-1.41l-2.34-2.34c-.2-.2-.45-.29-.71-.29zm-3.6 3.19L3 17.25V21h3.75L17.81 9.94l-3.75-3.75z"][];
  ]

let delete_forever ~label ~class_attr =
  svg_elt "svg" ~a:[attr "width" "1.5em"; attr "height" "1.5em"; attr "fill" "currentColor"; attr "class" class_attr;
                    attr "viewBox" "0 0 24 24"; attr "enable-background" "new 0 0 24 24"; attr "aria-labelledby" "icon-title-delete-forever"; attr "role" "img"] [
    svg_elt "title" ~a:[attr "id" "icon-title-delete-forever"] [text label];
    svg_elt "path" ~a:[attr "d" "M0 0h24v24H0V0z"; attr "fill" "none"][];
    svg_elt "path" ~a:[attr "d" "M14.12 10.47L12 12.59l-2.13-2.12-1.41 1.41L10.59 14l-2.12 2.12 1.41 1.41L12 15.41l2.12 2.12 1.41-1.41L13.41 14l2.12-2.12zM15.5 4l-1-1h-5l-1 1H5v2h14V4zM6 19c0 1.1.9 2 2 2h8c1.1 0 2-.9 2-2V7H6v12zM8 9h8v10H8V9z"][];
  ]
