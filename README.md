### How to use
```
    _rollerView = [[CzyImageRollerView alloc] initWithFrame:self.view.bounds];
    
    //设置url数组
    _rollerView.imageUrls = [self imageUrls].mutableCopy;
    
    //设置页码样式
    _rollerView.pageStyle = CzyPageStyleDot;
    
    [self.view addSubview:_rollerView];
```

### bar style
![bar](https://github.com/ITIosEthan/CzyRoller/blob/master/bar.gif)

### dot style
![dot](https://github.com/ITIosEthan/CzyRoller/blob/master/dot.gif)
