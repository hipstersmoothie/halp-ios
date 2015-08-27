func | <T:Equatable>(lhs:[T], rhs:[T])->[T] {
    var result = lhs
    for e in rhs {
        if !Swift.contains(lhs, e){ result.append(e) }
    }
    return result
}