---
layout: post
title: Including figures in two-column LaTeX documents
category:
 - computer-science
 - notes
toc: false
author: Clément Durand
---

*On how to correctly put figures in your LaTeX document when you have two
columns.*

---

This post is biased for some parameters are chosen to correctly put figures
in conference papers.

Assume that you want to include a picture in your two-column document. The
basic way to do this is to use the `figure` environment along with the
`\includegraphics` command from the `graphicx` package. The relevant parts
of the code are detailed below.

```tex
\documentclass[conference]{IEEEtran}
% ...
\usepackage{graphicx}
% ...
\begin{document}
  % ...

  \begin{figure}[!ht]
    \center
    \includegraphics[width=\linewidth]{graphics/schema.jpg}
    \caption{\label{schema}My beautiful schema}
  \end{figure}

  As shown in figure \ref{schema}, this model allows...

  % ...
\end{document}
```

Now, if your picture is wide and it is not readable only in one column,
you can make it span on the full width of the paper.

```tex
\documentclass[conference]{IEEEtran}
% ...
\usepackage{graphicx}
% ...
\begin{document}
  % ...

  \begin{figure*}[!ht]
    \center
    \includegraphics[width=\textwidth]{graphics/schema.jpg}
    \caption{\label{schema}My beautiful schema}
  \end{figure*}

  As shown in figure \ref{schema}, this model allows...

  % ...
\end{document}
```

There are actually only two differences. The `figure*` environment is
used instead of `figure`, and the width of the included graphics is
`\textwidth` instead of `\linewidth`.

If you want to adjust the size of your image, you can put a number in the
length. A good way to do this is to write `width=0.8\linewidth` or
`width=0.8\textwidth` for example, depending on your use case.
