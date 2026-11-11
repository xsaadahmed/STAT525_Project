# Quick setup for teammates

1. Send me your GitHub username so I can invite you to the private repository. Accept the invitation before cloning.
2. Install R, RStudio Desktop, and Git if needed. Restart RStudio after installing Git.
3. In RStudio, choose **File → New Project → Version Control → Git**.
4. Paste `https://github.com/xsaadahmed/STAT525_Project.git`, choose a local folder, and click **Create Project**. Authenticate with GitHub if prompted.
5. Open `STAT525_Project.Rproj` whenever you return to the project.
6. In the **Git** pane, **Pull** before working. Edit your assigned script, save, stage only your intended files, **Commit** with a short message, then **Push**. Pull again before pushing if others have added commits.

Coordinate before editing the shared data preparation script or report. If a pull or push reports a conflict, pause and resolve it together.

If the Git pane is missing, check **Tools → Global Options → Git/SVN** and restart RStudio.

Reference: [Posit RStudio version control guide](https://docs.posit.co/ide/user/ide/guide/tools/version-control.html).
