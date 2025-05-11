/**
MIT License

Copyright (c) 2025 Daniel Cota

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/
#include <cstdint>

// Golden ratio constant for LoopMix128 - golden ratio fractional part * 2^64
const uint64_t GR = 0x9e3779b97f4a7c15ULL;

// For LoopMix128
uint64_t fast_loop = 0xDEADBEEF12345678ULL;
uint64_t slow_loop = 0xABCDEF0123456789ULL;
uint64_t mix = 0x123456789ABCDEFULL;

static inline uint64_t rotateLeft(const uint64_t x, int k)
{
	return (x << k) | (x >> (64 - k));
}

static inline uint64_t loopMix128()
{
	uint64_t output = GR * (mix + fast_loop);

    if (fast_loop == 0)
	{
		slow_loop += GR;
		mix ^= slow_loop;
	}

	mix = rotateLeft(mix, 59) + fast_loop;
	fast_loop = rotateLeft(fast_loop, 47) + GR;

    return output;
}
