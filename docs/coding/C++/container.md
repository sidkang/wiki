# Sequential Containers

## STD Sequential Contianer Types

| Types        | Description         | Add or Delete Performance | Nonsequential Aceess Performance     |
| ------------ | ------------------- | ------------------------- | ------------------------------------ |
| vector       | flexible-size array | fast at back              | fast random access                   |
| deque        | double-ended queue  | fast at front and back    | fast random access                   |
| list         | doubly linked list  | fast at any element       | only bidirectional sequential access |
| forward_list | singly linked list  | fast at any element       | only sequential access               |
| array        | fixed-size array    | cannnot add or delete     | fast random access                   |
| string       |                     | fast at back              | fast random access                   |

```cpp
# include <iostream>

int main() {
    std::cout << std::unitbuf;
    std::cout << "123";
    std::cout << "456";
    std::cout << "789";
    std::cout << "hi!" << std::endl;   // writes hi and a newline, then flushes the buffer
    std::cout << "hi!" << std::flush;  // writes hi, then flushes the buffer; adds no data
    std::cout << '\\';
    std::cout << "hi!" << std::ends;   // writes hi and a null, then flushes the buffer
}
```

## Which Sequential Container to Use
- Unless you have a reason to use another container, use a vector.
- If your program has lots of small elements and space overhead matters, don’t use list or forward_list.
- If the program requires random access to elements, use a vector or a deque.
- If the program needs to insert or delete elements in the middle of the container, use a list or forward_list.
- If the program needs to insert or delete elements at the front and the back, but not in the middle, use a deque.
- If the program needs to insert elements in the middle of the container only while reading input, and subsequently needs random access to the elements:
    - First, decide whether you actually need to add elements in the middle of a container. It is often easier to append to a vector and then call the library sort function to reorder the container when you’re done with input.
    - If you must insert into the middle, consider using a list for the input phase. Once the input is complete, copy the list into a vector.