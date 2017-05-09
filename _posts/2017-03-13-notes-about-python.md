---
layout: post
title: Notes about python
category: computer-science
author: Clément Durand
---

*Random notes taken about python, style and my habits.*

---

# Time saving

## One-liners

```python
"""
if x:
    return y
else:
    return z
"""
return y if x else z
```

```python
""" creating a n*m null matrix
M=list()
for i in range(n):
    l=list()
    for j in range(m):
        l.append(0)
    M.append(l)
"""
M = [[0]*m for _ in range(n) ]
```

```python
""" copying a vector
u = [0]*len(U)
for i in range(len(U)):
    u[i]=U[i]
"""
u = [ x for x in U ]
```

```python
""" sum of two vectors
u = [0]*len(a)
for i in range(len(a)):
    u[i]=a[i]+b[i]
"""
u = [ a[i]+b[i] for i in range(len(a)) ]

# bonus :P
u = list(map(lambda x: x[0]+x[1],zip(a,b)))
```

# Common mistakes

```
""" creating 0 matrix
M = [[0]*n]*m
M[0][0]=1
print(M[1][0]) # will print 1 because
               # every M[i] is the same
               # list [0]*n
"""
M = [ [0]*n for _ in range(m) ]
```

# Style

avoid abusive casts. if you want to check the type while debugging, use prints, etc.

# Debugging and cross debugging

# Optimization

## Booleans

To evaluate a boolean, python first casts it to an int (0 or 1) and then
checks that it is not 0. It is then better to evaluate integers than
booleans, generally.

```python
""" bad version
if n!=0:
    # python evaluates n!=0 to True or False, then
    # converts the boolean to 1 or 0, and finally
    # checks if the result is non-zero
    print("ok")
"""
if n:
    print("ok")
```
