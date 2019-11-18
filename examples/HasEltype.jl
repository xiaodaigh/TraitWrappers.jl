using TraitWrappers
import Base: IteratorEltype, HasEltype

fn_holy(itr) = fn_holy(IteratorEltype(itr), itr)

fn_holy(::HasEltype, itr) = begin
	println("this itr has `eltype()` defined")
	println(itr)
end




fn_holy(1)
fn_tw(1)
