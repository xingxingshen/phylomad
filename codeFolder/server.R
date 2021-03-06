library(shiny)

options(shiny.maxRequestSize = 100*1024^2)

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {

   makeCheckboxTooltip <- function(checkboxValue, buttonLabel, Tooltip){
   tags$script(HTML(paste0("
          $(document).ready(function() {
            var inputElements = document.getElementsByTagName('input');
            for(var i = 0; i < inputElements.length; i++){
              var input = inputElements[i];

              if(input.getAttribute('value') == '", checkboxValue, "'){
                var buttonID = 'button_' + Math.floor(Math.random()*1000);

                var button = document.createElement('button');
                button.setAttribute('id', buttonID);
                button.setAttribute('type', 'button');
                button.setAttribute('class', 'btn action-button btn-inverse btn-xs');
                button.appendChild(document.createTextNode('", buttonLabel, "'));

                input.parentElement.parentElement.appendChild(button);
                shinyBS.addTooltip(buttonID, \"tooltip\", {\"placement\": \"bottom\", \"trigger\": \"hover\", \"title\": \"", Tooltip, "\"}) 
              };
            }
          });
        ")))
  }

  output$files = renderDataTable({
    files = list.files(readDirectoryInput(session, "directory"), full.names = T)
    data.frame(name = basename(files), file.info(files))
  })

  output$modeltestcode <- renderUI({
  		       source(paste0("testBackbones/", input$modeltotest, "/test.ui.R"), local = T)
  })

  observeEvent(input$startAnalysis, {
  		       showModal(modalDialog(
				title = "Are you sure?",
				h5("This will start model assessment."),
				h5("Progress will be shown in the terminal window (mac), or in the log file saved in the main PhyloMAd folder (windows)."),
				h6("License statement. Copyright (C) 2017 Authors. PhyloMAd is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version. This program is distributed in the hope that it will be useful but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License found in the folder codeFolder or see www.gnu.org/licenses/ for more details. Users must cite PhyML when using PhyloMAd as indicated in the manual."),
				easyClose = F,
				footer = tagList(
				       modalButton("Cancel"),
          			       actionButton("START", "START")
        			)
		      ))
  })

  observeEvent(input$START, {
  		       showModal(modalDialog(
				title = "Started! Assessment steps appear below on completion.",
				h5("'Close' will not stop the analysis (closing PhyloMAd will)."),
				h5("Avoid pressing START ANALYSIS again, since analyses will be run repeatedly."),
				h5("In the event of an error, PhyloMAd should be closed and reopened."),
				renderPrint(source(paste0("testBackbones/", input$modeltotest, "/test.server.R"), local = T)),
				easyClose = F,
				footer = modalButton("Close")
		       ))
  })

  session$onSessionEnded(function() { 
     stopApp()
     q("no") 
  })

  })