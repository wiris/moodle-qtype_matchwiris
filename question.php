<?php
// This file is part of Moodle - http://moodle.org/
//
// Moodle is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Moodle is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Moodle.  If not, see <http://www.gnu.org/licenses/>.

defined('MOODLE_INTERNAL') || die();
require_once($CFG->dirroot . '/question/type/wq/question.php');
require_once($CFG->dirroot . '/question/type/match/question.php');

class qtype_matchwiris_question extends qtype_wq_question implements question_automatically_gradable_with_countback {

    // References to moodle's question object.
    public $shufflestems;
    public $correctfeedback;
    public $correctfeedbackformat;
    public $partiallycorrectfeedback;
    public $partiallycorrectfeedbackformat;
    public $incorrectfeedback;
    public $incorrectfeedbackformat;
    public $stems;
    public $stemformat;
    public $choices;
    public $right;

    public $originalchoices;

    // Added override in order to exclude repeating values
    public function start_attempt(question_attempt_step $step, $variant) {

        if($this->originalchoices == null) {
            $this->originalchoices = array();
            $this->originalchoices = $this->base->choices;
        }

        parent::start_attempt($step, $variant);
        $this->extend_variables_and_check_right_array();

        // We call the parent start_attempt method again in order to set the choiceorder
        parent::start_attempt($step, $variant);
    }
    
    public function grade_response(array $response) {
        $this->extend_variables_and_check_right_array();

        list($right, $total) = $this->get_num_parts_right($response);
        $fraction = $right / $total;
        return array($fraction, question_state::graded_state_for_fraction($fraction));
    }

    public function join_all_text() {
        $text = parent::join_all_text();

        // Stems (matching left hand side).
        foreach ($this->stems as $key => $value) {
            $text .= ' ' . $value;
        }
        // Choices (matching right hand side).
        foreach ($this->originalchoices as $key => $value) {
            $text .= ' ' . $value;
        }
        // Combined feedback.
        $text .= ' ' . $this->correctfeedback . ' ' . $this->partiallycorrectfeedback . ' ' . $this->incorrectfeedback;

        return $text;
    }

    public function get_stem_order() {
        return $this->base->get_stem_order();
    }
    public function get_choice_order() {
        return $this->base->get_choice_order();
    }

    public function get_right_choice_for($stemid) {
        $this->extend_variables_and_check_right_array();

        return $this->base->get_right_choice_for($stemid);
    }


    public function get_correct_response() {
        $response = array();
        foreach ($this->base->get_stem_order() as $key => $stemid) {
            $response[$this->field($key)] = $this->get_right_choice_for($stemid);
        }
        return $response;
    }

    // Added in order to fix the issue where variables with duplicated values
    // may repeat choices and evaluate wrong.
    protected function extend_variables_and_check_right_array(){
        foreach ($this->base->choices as $choice) {
            $key = array_search($choice, $this->base->choices);
            $this->base->choices[$key] = $this->expand_variables_text($choice);
        }

        // Getting right array done again
        foreach($this->base->choices as $choice){
            $keys = array_keys($this->base->choices, $choice);
            if(count($keys) > 1) {
                $def_key = $keys[0];
                foreach($keys as $key) {
                    if($key != $keys[0]){
                        // We get rid of repeated choices
                        unset($this->base->choices[$key]);
                        $this->base->right[$key] = $def_key;
                    }
                } 
            }
        }
    }

    /**
     * @param int $key stem number
     * @return string the question-type variable name.
     */
    protected function field($key) {
        return 'sub' . $key;
    }
}
