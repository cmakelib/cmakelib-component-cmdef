
#ifndef RETURN_CODE
	#error "RETURN_CODE is not defined"
#endif

#ifdef DEBUG_FLAG_OK
	#define TEST_RETURN_CODE (0 + RETURN_CODE + RETURN_CODE_DEBUG)
#elif defined(RELEASE_FLAG_OK)
	#define TEST_RETURN_CODE (0 + RETURN_CODE + RETURN_CODE_RELEASE)
#else
	#error "Not supported build type!"
#endif



int main(void) {
	return TEST_RETURN_CODE;
}
