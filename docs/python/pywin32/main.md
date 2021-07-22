# Pywin32 Snippets

```python
from pathlib import Path
import win32com.client as win32

xl = win32.gencache.EnsureDispatch("Excel.Application")
xl = win32.dynamic.Dispatch("Excel.Application")  # Alternative
# win32.Dispatch("Excel.Application")  # Depreciated
```

Depreciation Reference: [win32.Dispatch vs win32.gencache in Python. What are the pros and cons?](https://stackoverflow.com/questions/50127959/win32-dispatch-vs-win32-gencache-in-python-what-are-the-pros-and-cons)

```python
from win32com.client import DispatchEx

excel = DispatchEx('Excel.Application')
excel.Visible = False
workbook_1 = excel.Workbooks.Open(r'C:\full\path\to\sales_summary.xlsx')
workbook_2 = excel.Workbooks.Open(r'C:\full\path\to\sales_template.xlsx')
workbook_2.Worksheets("Instructions").Move(Before=workbook_1.Worksheets("summary"))
workbook_1.SaveAs(r'C:\full\path\to\sales_summary_complete.xlsx')
excel.Application.Quit()
del excel
```
