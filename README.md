# Project: Final Exam Project in Logic Networks

## Overview

This project involves the design and implementation of a hardware module for logic networks as specified in the 2021/2022 Final Project for Logic Networks. The module retrieves sequences of 8-bit words from RAM, serializes them into a bit stream, encodes them using a convolutional code, and writes the processed bit stream back into memory. The core of the implementation is a state machine designed to manage the workflow efficiently.

---

## Architecture

### High-Level Description

The project is divided into five main components:
1. **Data Retrieval**: Fetches the number of words and the words to be encoded from RAM.
2. **Serialization**: Converts the words into a serial bit stream for encoding.
3. **Convolutional Encoding**: Applies the convolutional code to the bit stream.
4. **Parallelization**: Reassembles the encoded bit stream into 8-bit words.
5. **Memory Write**: Writes the processed words back to RAM.

The architecture is built around a **finite state machine (FSM)**, which controls the process in a sequential and efficient manner.

### FSM Description

The FSM operates through the following states:

- **RESET**: Initializes signals when the reset is activated.
- **IDLING**: Waits for the start signal.
- **READ-NWORD**: Reads the number of words to process.
- **SETTING-ADDRESS**: Calculates memory addresses for word retrieval.
- **READ-WORD**: Fetches the words from RAM.
- **PRE-CONV**: Serializes the words into a bit stream.
- **CONVOLUTION**: Encodes the bit stream using the convolutional code, handled by a secondary FSM with states S0, S1, S2, and S3.
- **POST-CONV**: Organizes the output from the convolution process into 16-bit vectors for memory writing.
- **SENDER1**: Sends the first 8-bit word (bits 15 to 8) to memory.
- **SENDER2**: Sends the second 8-bit word (bits 7 to 0) to memory and checks if processing is complete.
- **FINALIZE**: Waits for the start signal to deactivate before resetting the FSM.

---

## Experimental Results

### Synthesis

- The design uses **132 flip-flops** without inferring latches, ensuring correct post-synthesis functionality.
- Timing constraints are satisfied, with a clock cycle of **100 ns** and an arrival time of **5.958 ns**, giving a slack of **94.042 ns**.

### Simulations

1. **Output Verification**: Test benches confirm that the module correctly writes outputs to the proper RAM addresses for various input scenarios, including the maximum of 255 words.
2. **Reset Functionality**: Verified both the pre-computation reset and cases where the reset is triggered mid-computation.
3. **Edge Case - N-word = 0**: Ensured no RAM write occurs when the input word count is zero.
4. **Successive Computations**: Confirmed the module can encode multiple streams consecutively as per the specification.

---

## Conclusion

The project successfully implements a hardware module using a single process without external components, avoiding latches to maintain post-synthesis functionality. Extensive behavioral and post-synthesis testing demonstrates that the design meets all specified requirements and constraints.
