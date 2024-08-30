.LC1:
.string	"%lld\n"
.text
.globl	sum
.type	sum, @function
sum:


movq    $0, %rax
leave
ret
.LC2:
.string	"%lld\n"
.text
.globl	main
.type	main, @function
main:
pushq	%rbp
movq	%rsp, %rbp
subq        $16, %rsp
movq        -8(%rbp),%r9
movq        %r9,-16(%rbp)
subq        $16, %rsp
movq        -24(%rbp),%r9
movq        %r9,-32(%rbp)
call	sum
popq	%rbp
subq        $16, %rsp
movq	%rax, -40(%rbp)
subq	 $16, %rsp
movq	 -40(%rbp) ,%r9
movq	 %r9, -48(%rbp)
movq	-48(%rbp), %rax
movq	%rax, %rsi
leaq        .LC2(%rip), %rax
movq	%rax, %rdi
movl	$0, %eax
call	printf@PLT
movq    $0, %rax
leave
ret
