function restore_listener() {
   document.getElementById('restore-file-input')?.addEventListener('change', read_restore, true);
}

function waitForElement(selector) {
    return new Promise((resolve) => {
        const observer = new MutationObserver((mutations, observer) => {
            const element = document.querySelector(selector);
            if (element) {
                observer.disconnect();
                resolve(element);
            }
        });

        observer.observe(document.body, {
            childList: true,
            subtree: true,
        });
    });
}

function restore_exercise(ee) {
   const e = ee.shift();
   if (!e) return;
   if (e.result != "TRUE") {
      restore_exercise(ee);
   } else {
      const label = e.label;
      const e_sel = `div.cell[data-exercise='${label}']`;
      const code_editor = document.querySelector(`${e_sel} div.cm-content`);
      code_editor.innerHTML = e.user_code;
      waitForElement(`${e_sel} div.cm-activeLine`).then(() => {
         document.querySelector(`${e_sel} a.exercise-editor-btn-run-code`).click()
         waitForElement(`${e_sel} div.alert-success`).then(() => {
            restore_exercise(ee);
         });
      });
   }
}

function read_restore() {

   var file = document.getElementById("restore-file-input").files[0];
   var reader = new FileReader();

   reader.onload = function() {
      const out = Papa.parse(reader.result, { header: true });
      restore_exercise(out.data);
   };

   if (file) {
      reader.readAsText(file);
   }

}