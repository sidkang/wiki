# Scirpt Inbox

## Convert Chart to Pictures

```python
for index in range(1, count + 1):
    currentChart = wbSheet.ChartObjects(index)
    currentChart.Copy
    currentChart.Chart.Export("chart" + str(index) + ".png")
```

## Paste to Word (!)
```vba
$default = [Type]::Missing
$wd.Selection.PasteSpecial($default, $default, $default, $default, 9, $default, $default)
```

## Find & Replace

[Replace 01](https://stackoverflow.com/questions/3022898/python-win32com-automating-word-how-to-replace-text-in-a-text-box)
[Replace 02](https://stackoverflow.com/questions/35082380/how-can-i-open-a-docx-file-find-a-particular-string-occurring-at-multiple-place/35084050#35084050)
[Replace 03](https://stackoverflow.com/questions/1045628/can-i-use-win32-com-to-replace-text-inside-a-word-document)
[Replace 04](https://github.com/MrFiona/python_learning/blob/37f09f478e921f875c63296694fbd030e3e4d4c5/python_program/Tkinter/auto_doc_generate.py)

## Line Break in Word

"^p\n"

## Tips

[01](http://new.galalaly.me/2011/09/use-python-to-parse-microsoft-word-documents-using-pywin32-library/)
[02](https://github.com/fhopecc/stxt/blob/6d33f0bebe2820bcc1ecca9330abe36ff6aa3d0c/lib/stxt/formater/word14.py)
